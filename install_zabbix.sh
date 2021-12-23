#!/usr/bin/env bash

echo "Instalando MySql..."
echo ""
yum update -y && yum install vim wget -y
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm &> /dev/null
rpm -Uvh mysql80-community-release-el7-3.noarch.rpm &> /dev/null
yum install mysql-server -y &> /dev/null
systemctl start mysqld
if [ "$?" = "0" ]; then
    #PWD_MYSQL=$(grep 'password' /var/log/mysqld.log | cut -d ':' -f4 | sed 's/^ *//')
    #MYSQL=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $13}')
    MYSQL=$(grep -i 'password' /var/log/mysqld.log | awk '{split($0,a,": "); print a[2]}')
fi

############### Criando senha user root e zabbix ######################################
echo "Instalando expect..."
echo ""
yum install expect -y &> /dev/null
MYSQL_ROOT_PASSWORD="Station-1f21!@#:"  #Informe aqui sua senha de root
MYSQL_ZABBIX_PASSWORD="Station-1f31!@#"   #Informe aqui sue senha do usuario zabbix

echo "--> Set root password"
expect -f - <<-EOF
set timeout 10
spawn mysql_secure_installation
expect "Enter password for user root:"
send "$MYSQL\r"

expect "New password:"
send "$MYSQL_ROOT_PASSWORD\r"

expect "Re-enter new password:"
send "$MYSQL_ROOT_PASSWORD\r"

expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
send "n\r"

expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
send "y\r"
expect eof
EOF
# Did it work?
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1+1";
[ "$?" = "0" ] && echo "Root configurado com Sucesso" >> /home/vagrant/logzabbix.txt || echo "Erro ao configurar root" >> /home/vagrant/logzabbix.txt
yum remove expect -y

# --> Criando BD e user zabbix
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -s <<EOF 2>&1 | grep -v "Warning"
create database zabbix character set utf8 collate utf8_bin;
create user zabbix@localhost identified by '${MYSQL_ZABBIX_PASSWORD}';
grant all privileges on zabbix.* to zabbix@localhost;
EOF

########################### Instalando Zabbix 5 ##################################
echo "Instalando zabbix..."
echo ""
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm &> /dev/null
yum clean all &> /dev/null
yum install zabbix-server-mysql zabbix-agent -y &> /dev/null
yum install centos-release-scl -y &> /dev/null
#grep -A 3 "zabbix-frontend" /etc/yum.repos.d/zabbix.repo | grep enabled
sed -i '11s/0$/1/' /etc/yum.repos.d/zabbix.repo # Precisa melhorar
yum install zabbix-web-mysql-scl zabbix-apache-conf-scl -y &> /dev/null

#--> Importando schema inicial
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p${MYSQL_ZABBIX_PASSWORD} zabbix
[ "$?" = "0" ] && echo "Schema criado com ucesso" >> /home/vagrant/logzabbix.txt || echo "Erro ao crizar schema inicial" >> /home/vagrant/logzabbix.txt

# --> Adicionando a senha do user zabbix
sed -in "s/# DBPassword=/DBPassword=$MYSQL_ZABBIX_PASSWORD/" /etc/zabbix/zabbix_server.conf

# --> Ajustando timezone
echo "php_value[date.timezone] = America/Sao_Paulo" >> /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf

# --> Restartando os serviços
systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm && systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm

# --> Testando site
wget -S --spider localhost/zabbix &> /dev/null
if [ "$?" = "0" ]; then
        echo "Zabbix Online!" >> /home/vagrant/logzabbix.txt
else
        echo "Zabbix Offline" >> /home/vagrant/logzabbix.txt
fi

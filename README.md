# Automatizando a criação de um servidor Zabbix
---
Arquivos para automatizar a configuração de um BD MySql para um server Zabbix

## Como funciona?
---
Utilizando o gerenciador de ciclo de vida ***Vagrant***, criei o arquivo 'Vagrantfile' você consegue otimizar a criação de um VM no VirtualBox para o projeto. Caso contrario, basta criar uma VM em qualquer virtualizador com no minimo 2GB de Ram, utilizando o sistema CentOS 7, conforme orientação do site oficial do Zabbix.
Porem os arquivos de log serao salvos no diretorio */home/vagrant*.
O segunda arquivo 'install_zabbix.sh' automatiza quase todo o processo, devendo o usuário informar a senha do ROOT e do ZABBIX (linhas 21/31).


### Lembrando que este passo a passo é apenas para laboratórios, não recomendado para produção.

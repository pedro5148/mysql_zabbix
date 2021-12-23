# -*- mode: ruby -*- 
# vi: set ft=ruby :

# Vagrant Settings
Vagrant.configure("2") do |config|

  config.vm.define "zabbix" do |cfg|
    #cfg.vm.box = "debian/stretch64" 	#debian 9
    #cfg.vm.box = "debian/buster64" 	#debian 10
    #cfg.vm.box = "ubuntu/focal64" 	#ubuntu 20.04
    #cfg.vm.box = "ubuntu/bionic64" 	#ubuntu 18.04
    #cfg.vm.box = "centos/8"
    cfg.vm.box = "centos/7"
    cfg.vm.hostname = "zabbix-server"
    cfg.vm.box_check_update = false
    #cfg.vm.network "private_network", ip: "192.168.33.101"
    cfg.vm.network "public_network", bridge: "wlp3s0", ip: "192.168.1.151"
    
    #Virtualbox Settings
    cfg.vm.provider "virtualbox" do |vb| 
      vb.gui = false
      vb.name = "v_Zabbix"
      #vb.name = "v_zabbix_teste"
      vb.memory = "2048"
      vb.cpus = "2"
    end
  end
  
  #teste
config.vm.provision "shell", path: "install_zabbix.sh"

  #config.vm.provision "shell", inline: <<-SHELL
   # echo "sudo su -" >> .bashrc

  #SHELL 
end

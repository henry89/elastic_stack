# -*- mode: ruby -*-
# vi: set ft=ruby :

#yaml module required for importing the settings stored in servers.yml
require "yaml"

servers = YAML.load_file("./files/servers.yml")

Vagrant.configure("2") do |config|
  
  config.vagrant.plugins =["vagrant-berkshelf", "vagrant-omnibus"]
  
  # force update
  config.vbguest.auto_update = true
  config.omnibus.chef_version = :latest

  #enable berkself by supplying path
  config.berkshelf.berksfile_path = './files/berkshelf'

  ### servers ###
  servers["servers"].each do |host|
    config.vm.box = "bento/centos-7"
    #not working when version is specified, was for centos/8
      #config.vm.box_version = "1905.1"
    config.vm.define host['name'] do |define|
      define.vm.hostname = host['name']
      define.vm.provider "virtualbox" do |vb|
        vb.name = host['name']
        vb.cpus = host['cpu']
        vb.memory = host['memory']
      end
      define.vm.network "private_network", ip: host['ip']
      # if host['name'] =~ /kib/
      #   config.vm.network "forwarded_port", guest: 80, host: 5601, host_ip: "10.10.10.30"
      # end
      define.ssh.forward_agent = true
      define.vm.provision "chef_solo" do |chef|
        chef.arguments = "--chef-license accept"
        chef.provisioning_path = "/var/chef"
        chef.cookbooks_path = ["chef/cookbooks"]
        chef.roles_path = "chef/roles"
        if host['name'] =~ /kib/
          chef.add_role  ('kibana')
        end
        if host['name'] =~ /elk/
          chef.add_role  ('elasticsearch')
        end
        if host['name'] =~ /logs/
          chef.add_role  ('logstash')
        end
      end
    end
  end
end
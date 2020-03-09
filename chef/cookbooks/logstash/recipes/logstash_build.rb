#return output of shell commands - Will be using ot make cookbook more idempotency (run checks if not exist/valid before execution)
require 'mixlib/shellout'

#install Java first
package 'java-11-openjdk-devel'

# Updates file with JAVA_HOME Settings
template '.bashrc' do 
    source 'home/bashrc.erb'
    action :create
end

=begin    
install logstash, will run check to see if logstash 7.6 version is installed 
before applying resources    
=end

#import PGP KEY
execute 'download_and_install_elasticsearch_public_key' do
    not_if "rpm -q logstash-7.6*"
    command 'sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch'
    notifies :create, 'template[/etc/yum.repos.d/logstash.repo]', :immediately
end

#create repo file 
template '/etc/yum.repos.d/logstash.repo' do 
    source 'etc/yum.repos.d/logstash.repo.erb'
    action :nothing
    owner 'root'
    group 'root'
    notifies :run, 'execute[install_logstash]', :immediately
end

#sudo install logstash from repo that has been updated
execute 'install_logstash' do 
    command 'sudo yum install logstash -y'
    action :nothing
    notifies :create, 'template[/etc/logstash/logstash.yml]', :immediately
end

#logstash service
service 'logstash.service' do
    supports :status => true, :restart => true, :reload => true
    action :enable
    subscribes :reload, 'template[/etc/logstash/logstash.yml]', :immediately
end

#update the logstash yml file
template '/etc/logstash/logstash.yml' do
    source 'etc/logstash/logstash.yml.erb'
    action :nothing
end


#update the JVM options file
template '/etc/logstash/jvm.options' do
    source 'etc/logstash/jvm.options.erb'
    action :create
    notifies :restart, 'service[logstash.service]', :immediately
end

#install filebeat
execute 'install_Filebeat' do 
    command 'sudo yum install filebeat -y'
    notifies :create, 'template[/etc/filebeat/filebeat.yml]', :immediately
end 

#edit filebeat yml
template '/etc/filebeat/filebeat.yml' do 
    source 'etc/filebeat/filbeat.yml.erb'
    action :nothing
    notifies :create, 'template[/etc/logstash/conf.d/auditbeat.conf]', :immediately
end

#configure logstash for filebeat input
template '/etc/logstash/conf.d/auditbeat.conf' do
    source 'etc/logstash/conf.d/auditbeat.conf.erb'
    action :create
    notifies :restart, 'service[filebeat.service]', :immediately
end

#restart filebeat service
service 'filebeat.service' do
    supports :status => true, :restart => true, :reload => true
    action :enable
    subscribes :restart, 'template[/etc/filebeat/filebeat.yml]', :immediately
end


#enable firewalld and/or reload settings, triggers after logstash install
service 'firewalld' do 
    supports :status => true, :restart => true, :reload => true
    action :enable
    subscribes :start, 'execute[install_logstash]', :immediately
end

# enable filebeat port
execute 'allow_ports' do
    output = Mixlib::ShellOut.new('sudo firewall-cmd --list-ports').stdout
    print(output)
    command 'firewall-cmd --permanent --add-port=5044/tcp'
    notifies :reload, 'service[firewalld]', :immediately
    # only_if { output.stdout != '5400/tcp' } 
end


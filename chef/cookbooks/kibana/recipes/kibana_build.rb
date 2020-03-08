=begin    
install kibana, will run check to see if kibana 7.6 version is installed 
before applying resources    
=end

#import PGP KEY
execute 'download_and_install_elasticsearch_public_key' do
    not_if "rpm -q kibana-7.6*"
    command 'sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch'
    notifies :create, 'template[/etc/yum.repos.d/kibana.repo]', :immediately
end

#create repo file 
template '/etc/yum.repos.d/kibana.repo' do 
    source 'etc/yum.repos.d/kibana.repo.erb'
    action :nothing
    owner 'root'
    group 'root'
    notifies :run, 'execute[install_kibana]', :immediately
end

#sudo install kibana from repo that has been updated
execute 'install_kibana' do 
    command 'sudo yum install kibana -y'
    action :nothing
    notifies :create, 'template[/etc/kibana/kibana.yml]', :immediately
end

#update the kibana yml file
template '/etc/kibana/kibana.yml' do
    source 'etc/kibana/kibana.yml.erb'
    action :nothing
end

#Kibana service
service 'kibana.service' do
    supports :status => true, :restart => true, :reload => true
    action :enable
    subscribes :reload, 'template[/etc/kibana/kibana.yml]', :immediately
end


#enable firewalld and/or reload settings, triggers after logstash install
service 'firewalld' do 
    supports :status => true, :restart => true, :reload => true
    action :enable
    subscribes :start, 'execute[install_kibana]', :immediately
end

# enable filebeat port
execute 'allow_ports' do
    # output = Mixlib::ShellOut.new('sudo firewall-cmd --list-ports').stdout
    # print(output)
    command 'firewall-cmd --permanent --add-port={5061,80}/tcp'
    notifies :reload, 'service[firewalld]', :immediately
    # only_if { output.stdout != '5601/tcp' } 
end

execute 'allow_http_service' do 
    command 'firewall-cmd --permanent --add-service=http'
    action :nothing
    subscribes :run, 'execute[allow_ports]', :immediately
    notifies :reload, 'service[firewalld]', :immediately
end

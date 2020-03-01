#Install elasticsearch from the RPM repo

# Import the Elasticsearch PGP Key
execute 'download_and_install_elasticsearch_public_key' do
    command 'sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch'
end

#create repo file 
template '/etc/yum.repos.d/elasticsearch.repo' do 
    source 'etc/yum.repos.d/elasticsearch.repo.erb'
    action :create
    owner 'root'
    group 'root'
end

#sudo install elasticsearch from repo
execute 'install_elasticsearch' do 
    command 'sudo yum install --enablerepo=elasticsearch elasticsearch -y'
end

#enable elasticsearch service to startup at boot
execute 'daemon-reload' do
    command 'sudo systemctl daemon-reload'
    notifies :restart, 'service[elasticsearch.service]', :immediately
end

#elasticsearch service
service 'elasticsearch.service' do 
    supports :status => true, :restart => true, :reload => true
end

#checks elastic is running
execute 'check_elasticsearch_port_9200' do 
    command 'curl -XGET 127.0.0.1:9200?pretty'
end


#open ports
# firewall_rule 'elasticsearch' do 
#     protocol :tcp
#     port [9200,9300]
#     command :allow
#     notifies :restart, 'service[firewalld]', :immediately
# end

#reload upsdated firewall settings
service 'firewalld' do 
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
    notifies :run, 'execute[daemon-reload]', :immediately
end

# not required as the install of elastic opens that port automatically
execute 'allow_ports' do
    command 'firewall-cmd --permanent --add-port={9200,9300}/tcp'
    notifies :restart, 'service[firewalld]', :immediately
end






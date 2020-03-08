#return output of shell commands - Will be using ot make cookbook more idempotency (run checks if not exist/valid before execution)
require 'mixlib/shellout'


=begin    
Install elasticsearch from the RPM repo, will run check to see if elastic 7.6 version is installed 
before applying resources    
=end

# Import the Elasticsearch PGP Key
execute 'download_and_install_elasticsearch_public_key' do
    not_if "rpm -q elasticsearch-7.6*"
    command 'sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch'
    notifies :create, 'template[/etc/yum.repos.d/elasticsearch.repo]', :immediately
end

#create repo file 
template '/etc/yum.repos.d/elasticsearch.repo' do 
    source 'etc/yum.repos.d/elasticsearch.repo.erb'
    action :nothing
    owner 'root'
    group 'root'
    notifies :run, 'execute[install_elasticsearch]', :immediately
end

#sudo install elasticsearch from repo
execute 'install_elasticsearch' do 
    command 'sudo yum install --enablerepo=elasticsearch elasticsearch -y'
    action :nothing
    notifies :create, 'template[/etc/elasticsearch/elasticsearch.yml]', :immediately
end

# update the elasticsearch configuration
template '/etc/elasticsearch/elasticsearch.yml' do 
    source 'etc/elasticsearch/elasticsearch.yml.erb'
    action :nothing
    notifies :run, 'execute[daemon-reload]', :immediately
end

#enable daemon-reload service to startup at boot
execute 'daemon-reload' do
    command 'sudo systemctl daemon-reload'
    notifies :restart, 'service[elasticsearch.service]', :immediately
end

# elasticsearch service
service 'elasticsearch.service' do 
    supports :status => true, :restart => true, :reload => true
    action :enable
    notifies :run, 'execute[check_elasticsearch_port_9200]', :immediately
end

#checks elastic is running
execute 'check_elasticsearch_port_9200' do 
    command 'curl -XGET  127.0.0.1:9200?pretty'
    action :nothing
end


=begin
    @todo make more idempotency, currentlty applies even when the ports are already enabled 
=end

#enable firewalld and/or reload settings
service 'firewalld' do 
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
    notifies :restart, 'service[elasticsearch.service]', :immediately
end

# not required as the install of elastic opens that port automatically
execute 'allow_ports' do
    output = Mixlib::ShellOut.new('sudo firewall-cmd --list-ports').stdout
    print(output)
    command 'firewall-cmd --permanent --add-port={9200,9300}/tcp'
    notifies :restart, 'service[firewalld]', :immediately
    # only_if { output.stdout != '9200/tcp 9300/tcp' } 
end


### updating the jvmp option file (not required atm), will use default for now





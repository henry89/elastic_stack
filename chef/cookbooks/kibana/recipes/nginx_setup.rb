#add nginx package repo
template '/etc/yum.repos.d/nginx.repo' do
    source 'etc/yum.repos.d/nginx.repo.erb'
    action :create
    notifies :run, 'execute[nginx_install]', :immediately
end

#nginx package install
execute 'nginx_install' do
    not_if "rpm -q nginx"
    command 'sudo yum install nginx -y'
    action :nothing
    notifies :create, 'template[/etc/nginx/nginx.conf]', :immediately
end

# # will comment out the server block as it will be using the kibana.conf server params
template '/etc/nginx/nginx.conf' do
    source 'etc/nginx/nginx.conf.erb'   
    action :nothing
    notifies :create, 'template[/etc/nginx/conf.d/kibana.conf]', :immediately
end

# creates a proxy path, rather then directly hitting port 5601
template '/etc/nginx/conf.d/kibana.conf' do
    source 'etc/nginx/conf.d/kibana.conf.erb'
    action :nothing
end

# triggered by tempate resource
service 'nginx.service' do
    supports :status => true, :restart => true, :reload => true
    action :enable
    subscribes :restart, 'template[/etc/nginx/nginx.conf]', :immediately
end

# restart kibana
service 'kibana.service' do
    supports :status => true, :restart => true, :reload => true
    subscribes :restart, 'template[/etc/nginx/conf.d/kibana.conf]', :immediately
    notifies :restart, 'service[nginx.service]', :immediately
end

#delete the default config file
file '/etc/nginx/conf.d/default.conf' do
    action :delete
end


# port 80 is enabled in kibana_build recipe









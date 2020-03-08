#add nginx package repo
template '/etc/yum.repos.d/nginx.repo' do
    source 'etc/yum.repos.d/nginx.repo.erb'
    action :create
end

#nginx package install
package 'nginx' do
    not_if "rpm -q nginx"
    action :install
end

# # will comment out the server block as it will be using the kibana.conf server params
template '/etc/nginx/nginx.conf' do
    source 'etc/nginx/nginx.conf.erb'   
    action :create
    notifies :restart, 'service[nginx.service]', :immediately
end

# creates a proxy path, rather then directly hitting port 5601
template '/etc/nginx/conf.d/kibana.conf' do
    source 'etc/nginx/conf.d/kibana.conf.erb'
    action :create
    notifies :restart, 'service[nginx.service]', :immediately
end

# triggered by tempate resource
service 'nginx.service' do
    supports :status => true, :restart => true, :reload => true
    action :enable
end

#delete the default config file
file '/etc/nginx/conf.d/default.conf' do
    action :delete
end


# port 80 is enabled in kibana_build recipe









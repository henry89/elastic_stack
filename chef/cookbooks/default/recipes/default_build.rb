package 'tree'

package 'net-tools'

execute 'yum_update_upgrade' do
    command 'sudo yum update -y && sudo yum upgrade -y'
end

template '/etc/motd' do 
    source 'etc/motd.erb'
    variables(
        :teamname => 'Operational Analytics'
    )
    action :create
    owner 'root'
    group 'root'
end
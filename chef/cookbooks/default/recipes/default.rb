package 'tree'

execute 'yum_update_upgrade' do
    command 'sudo yum update && sudo yum upgrade'
end

template '/etc/modtd' do 
    source 'etc/motd.erb'
    variables(
        :teamname => 'Operational Analytics'
    )
    action :create
    owner 'root'
    group 'root'
end





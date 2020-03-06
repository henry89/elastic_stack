#install Java first
package 'java-11-openjdk-devel'

template '~/.bashrc' do 
    source: 'home/bashrc.erb'
end
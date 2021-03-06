package 'etckeeper' do
  action :install
  notifies :run, 'execute[etckeeper-init]', :immediately
end

execute 'etckeeper-init' do
  command 'etckeeper init'
  creates '/etc/.git'
  notifies :create, 'template[gitconfig]', :immediately
end

template 'gitconfig' do
  path '/etc/.git/config'
  owner 'root'
  group 'root'
  mode '0644'
end

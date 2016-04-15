package 'etckeeper' do
  action :install
  notifies :run, 'execute[etckeeper]', :immediately
end

execute 'etckeeper-init' do
  command 'etckeeper init'
  creates '/etc/.git'
  notifies :template, 'template[gitconfig]', :immediately
end

template 'gitconfig' do
  path '/etc/.git/config'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  subscribes :run, 'execute[etckeeper]', :immediately
end



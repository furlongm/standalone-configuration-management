package 'screen' do
  action :install
end

cookbook_file 'screenrc' do
  path '/etc/screenrc'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

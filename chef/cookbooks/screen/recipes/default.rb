package 'screen' do
  action :install
end

cookbook_file 'screenrc' do
  path '/etc/screenrc'
  action :create_if_missing
end

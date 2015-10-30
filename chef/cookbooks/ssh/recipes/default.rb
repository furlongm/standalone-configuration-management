package 'openssh' do
  package_name node['ssh']['package']
  action :install
end

service 'openssh' do
  service_name node['ssh']['service']
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

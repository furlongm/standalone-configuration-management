package 'haveged' do
  action :install
end

service 'haveged' do
  action [:enable, :start]
  not_if { node['containerized'] }
end

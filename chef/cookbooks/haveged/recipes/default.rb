package 'haveged' do
  action :install
end

service 'haveged' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

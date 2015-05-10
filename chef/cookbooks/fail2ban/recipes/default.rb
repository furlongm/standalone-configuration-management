package 'fail2ban' do
  action :install
end

service 'fail2ban' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

cookbook_file 'fail2ban.local' do
  path '/etc/fail2ban/fail2ban.local'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  notifies :restart, 'service[fail2ban]'
end

case node['platform_family']
  when 'debian'
    logfile = '/var/log/auth.log'
  when 'rhel'
    logfile = '/var/log/secure'
  when 'suse'
    logfile = '/var/log/messages'
end

template 'jail.local' do
  path '/etc/fail2ban/jail.local'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  variables(
    :logfile => logfile
  )
  notifies :restart, 'service[fail2ban]'
end

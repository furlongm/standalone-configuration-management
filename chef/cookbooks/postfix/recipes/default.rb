package 'postfix' do
  action :install
end

package 'mailx' do
  action :install
end

service 'postfix' do
  supports :status => true, :restart => true, :reload => true
end

case node['platform_family']
  when 'debian'
    logfile = '/var/log/auth.log'
  when 'rhel'
    logfile = '/var/log/secure'
  when 'suse'
    logfile = '/var/log/messages'
end

template 'main.cf' do
  path '/etc/postfix/main.cf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  variables(
    :logfile => logfile
  )
  notifies :restart, 'service[fail2ban]'
end

case node['platform_family']
  when 'debian'
    mailx = 'bsd-mailx'
    logfile = '/var/log/auth.log'
  when 'rhel'
    logfile = '/var/log/secure'
    mailx = 'mailx'
  when 'suse'
    logfile = '/var/log/messages'
    mailx = 'mailx'
end

package ['postfix', mailx] do
  action :install
end

service 'postfix' do
  supports :status => true, :restart => true, :reload => true
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
  notifies :restart, 'service[postfix]'
end

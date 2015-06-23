case node['platform_family']
  when 'debian'
    exim = 'exim4'
    mailx = 'bsd-mailx'
    logfile = '/var/log/auth.log'
  when 'rhel'
    exim = 'exim'
    logfile = '/var/log/secure'
    mailx = 'mailx'
  when 'suse'
    exim = 'exim'
    logfile = '/var/log/messages'
    mailx = 'mailx'
end

package exim do:
  action :remove
end

package ['postfix', mailx] do
  action :install
end

service 'postfix' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
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

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

package exim do
  action :remove
end

package mailx do
  action :install
end

package 'postfix' do
  action :install
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

service 'postfix' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

ruby_block 'add_root_mail_alias' do
  block do
    mail_alias = 'root: ' + node[:postfix][:root_mail_alias]
    file = Chef::Util::FileEdit.new('/etc/aliases')
    file.search_file_replace_line(/^root:/, mail_alias)
    file.insert_line_if_no_match(/^root:/, mail_alias)
    file.write_file
  end
  notifies :run, 'execute[run-newaliases]', :immediately
end

execute 'run-newaliases' do
  command '/usr/bin/newaliases'
  action :nothing
  notifies :restart, 'service[postfix]'
end

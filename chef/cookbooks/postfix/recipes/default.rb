if platform_family?('debian')
  exim = 'exim4'
  mailx = 'bsd-mailx'
else
  exim = 'exim'
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

if platform_family?('debian', 'fedora')
  package 'postfix-lmdb' do
    action :install
  end
end

template 'main.cf' do
  path '/etc/postfix/main.cf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  notifies :restart, 'service[postfix]'
end

service 'postfix' do
  action [:enable, :start]
  not_if { node['virtualization']['system'] == 'docker' }
end

ruby_block 'add_root_mail_alias' do
  block do
    mail_alias = 'root: ' + node['postfix']['root_mail_alias']
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

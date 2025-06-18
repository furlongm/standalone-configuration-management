locale = node['locales']['locale']
timezone = node['locales']['timezone']

package node['locales']['package'] do
  action :install
end

if platform_family?('debian')
  file '/etc/locale.gen' do
    content  "#{locale} UTF-8\n"
    mode     '0644'
    owner    'root'
    group    'root'
    notifies :run, 'execute[locale-gen]'
  end

  template 'environment' do
    path     '/etc/environment'
    mode     '0644'
    owner    'root'
    group    'root'
    notifies :run, 'execute[locale-gen]'
  end

  execute 'locale-gen' do
    command 'locale-gen'
    action  :nothing
  end
end

execute 'set-locale' do
  command "localectl set-locale LANG=#{locale}"
  not_if  { node['containerized'] }
  not_if  "localectl status | grep #{locale}"
end

execute 'set-timezone' do
  command "timedatectl set-timezone #{timezone}"
  not_if  { node['containerized'] }
  not_if  "timedatectl status | grep #{timezone}"
end

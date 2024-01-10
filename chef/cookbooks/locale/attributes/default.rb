case node['platform_family']
when 'debian'
  default['locales']['package'] = 'locales'
when 'rhel'
  default['locales']['package'] = 'glibc-common'
when 'fedora'
  default['locales']['package'] = 'glibc-common'
when 'suse'
  default['locales']['package'] = 'glibc-locale'
end

default['locales']['locale'] = 'en_US.UTF-8'
default['locales']['timezone'] = 'America/New_York'

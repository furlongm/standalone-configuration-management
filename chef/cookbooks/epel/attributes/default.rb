default['epel-release']['package'] = 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm'

if node['platform'] == 'centos'
  default['epel-release']['package'] = 'epel-release'
end

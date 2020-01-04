misc_packages = [
  'htop',
  'tree',
  'git',
  'strace',
  'mlocate',
  'diffstat',
  'bash-completion',
  'pwgen',
  'lsof',
]

net_packages += ['multitail'] unless node['platform_family'] == 'rhel'

package misc_packages do
  action :install
end

case node['platform_family']
when 'debian'
  debian_packages = [
    'debian-goodies',
    'apt-transport-https',
  ]
  package debian_packages do
    action :install
  end
end

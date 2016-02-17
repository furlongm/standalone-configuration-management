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
  'multitail',
]

package misc_packages do
  action :install
end

case node['platform_family']
when 'debian'
  package 'debian-goodies' do
    action :install
  end
end

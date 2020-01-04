misc_packages = %w(
  htop
  tree
  git
  strace
  mlocate
  diffstat
  bash-completion
  pwgen
  lsof
)

misc_packages += %w(multitail) unless node['platform_family'] == 'rhel'

misc_packages += %w(debian-goodies apt-transport-https) if node['platform_family'] == 'debian'

package misc_packages do
  action :install
end

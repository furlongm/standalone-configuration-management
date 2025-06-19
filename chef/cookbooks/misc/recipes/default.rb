misc_packages = %w(
  htop
  tree
  git
  strace
  diffstat
  bash-completion
  pwgen
  lsof
  multitail
  plocate
)

misc_packages += %w(debian-goodies apt-transport-https) if platform_family?('debian')

package misc_packages do
  action :install
end

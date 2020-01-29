net_packages = %w(
  ethtool
  tcpdump
  nmap
  telnet
  iftop
  whois
  wget
  ipset
  nload
)

net_packages += [node['bind-utils']['package']]
net_packages += [node['iperf']['package']]
net_packages += %w(bmon) unless platform_family?('rhel')

package net_packages do
  action :install
end

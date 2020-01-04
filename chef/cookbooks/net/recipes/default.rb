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
  node['bind-utils']['package']
  node['iperf']['package']
)

net_packages += %w(bmon) unless node['platform_family'] == 'rhel'

package net_packages do
  action :install
end

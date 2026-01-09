net_packages = %w(
  ethtool
  tcpdump
  nmap
  telnet
  iftop
  whois
  wget2
  ipset
  nload
)

net_packages += [node['bind-utils']['package']]
net_packages += [node['iperf']['package']]

package net_packages do
  action :install
end

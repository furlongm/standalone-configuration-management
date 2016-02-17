net_packages = [
  'ethtool',
  'tcpdump',
  'nmap',
  'telnet',
  'iftop',
  'whois',
  'wget',
  'iperf',
  'ipset',
]

package net_packages do
  action :install
end

package 'bind-utils' do
  package_name node['bind-utils']['package']
  action :install
end

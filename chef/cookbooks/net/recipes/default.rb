net_packages = [
  'ethtool',
  'tcpdump',
  'nmap',
  'telnet',
  'iftop',
  'whois',
  'wget',
  'ipset',
  'nload',
]

net_packages += ['bmon'] unless node['platform_family'] == 'rhel'

package net_packages do
  action :install
end

package 'bind-utils' do
  package_name node['bind-utils']['package']
  action :install
end

package 'iperf' do
  package_name node['iperf']['package']
  action :install
end

%w{ethtool tcpdump nmap telnet iftop whois}.each do |pkg|
  package pkg do
    action :install
  end
end

package 'bind-utils' do
  package_name node['bindutils']['package']
  action :install
end

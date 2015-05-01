%w{ethtool tcpdump nmap telnet iftop whois}.each do |pkg|
  package pkg do
    action :install
  end
end

case node['platform_family']
when 'debian'
  package 'dnsutils' do
    action :install
  end
when 'rhel', 'fedora', 'suse'
  package 'bind-utils' do
    action :install
  end
end

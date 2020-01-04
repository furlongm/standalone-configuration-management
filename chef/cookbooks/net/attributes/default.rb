default['bind-utils']['package'] = 'bind-utils'
default['iperf']['package'] = 'iperf3'

if node['platform_family'] == 'debian'
  default['bind-utils']['package'] = 'dnsutils'
end

if node['platform_family'] == 'suse'
  default['iperf']['package'] = 'iperf'
end

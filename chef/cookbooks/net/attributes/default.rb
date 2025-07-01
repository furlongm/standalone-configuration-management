default['bind-utils']['package'] = 'bind-utils'
default['iperf']['package'] = 'iperf3'

if platform_family?('debian')
  default['bind-utils']['package'] = 'bind9-dnsutils'
end

if platform_family?('suse')
  default['iperf']['package'] = 'iperf'
end

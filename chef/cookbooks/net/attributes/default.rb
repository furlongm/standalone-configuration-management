default['bind-utils']['package'] = 'bind-utils'

if node['platform_family'] == 'debian'
  default['binutils']['package'] = 'dnsutils'
end


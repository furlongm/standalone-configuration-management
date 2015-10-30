default['bind-utils']['package'] = 'bind-utils'

if node['platform_family'] == 'debian'
  default['bind-utils']['package'] = 'dnsutils'
end


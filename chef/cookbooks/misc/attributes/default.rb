default['locate']['package'] = 'mlocate'

if platform?('fedora')
  default['locate']['package'] = 'plocate'
end

if platform_family?('debian')
  default['locate']['package'] = 'plocate'
end

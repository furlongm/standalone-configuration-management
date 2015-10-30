default['ssh']['package'] = 'openssh-server'
default['ssh']['service'] = 'sshd'

case node['platform_family']
when 'debian'
  default['ssh']['service'] = 'ssh'
when 'suse'
  default['ssh']['package'] = 'openssh'
end

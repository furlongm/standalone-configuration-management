%w{htop tree git strace mlocate diffstat}.each do |pkg|
  package pkg do
    action :install
  end
end

case node['platform_family']
when 'debian'
  package 'debian-goodies' do
    action :install
  end
end

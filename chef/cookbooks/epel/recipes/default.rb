if platform_family?('rhel')

  execute 'dnf_makecache' do
    command '/usr/bin/dnf -y makecache'
    action :nothing
  end

  package 'epel-release' do
    source 'http://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm'
    action :install
    provider Chef::Provider::Package::Rpm
    notifies :run, 'execute[dnf_makecache]', :immediately
  end
end

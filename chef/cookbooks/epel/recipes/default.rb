if platform_family?('rhel')

  execute 'dnf_makecache' do
    command '/usr/bin/dnf -y makecache'
    action :nothing
  end

  package 'epel-release' do
    if node['platform'] == 'rocky'
      action :install
    else
      source "https://dl.fedoraproject.org/pub/epel/epel-release-latest-#{node['platform_version'].to_i}.noarch.rpm"
      provider Chef::Provider::Package::Rpm
    end
    notifies :run, 'execute[dnf_makecache]', :immediately
  end
end

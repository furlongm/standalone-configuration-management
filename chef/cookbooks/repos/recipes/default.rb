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

elsif platform_family?('suse')

  execute 'enable_non_oss_repo' do
    command 'zypper modifyrepo --enable "openSUSE:repo-non-oss"'
    only_if 'zypper lr "openSUSE:repo-non-oss"'
    not_if 'zypper lr --enabled "openSUSE:repo-non-oss"'
  end
end

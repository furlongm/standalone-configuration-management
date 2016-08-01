if node['platform_family'] == 'rhel'

  remote_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7' do
    source 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end

  execute 'yum_makecache' do
    command '/bin/yum -y makecache'
    action :nothing
  end

  package 'epel-release' do
    package_name node['epel-release']['package']
    action :install
    notifies :run, 'execute[yum_makecache]', :immediately
  end

end

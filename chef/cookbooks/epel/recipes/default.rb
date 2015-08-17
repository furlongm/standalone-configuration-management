if node['platform_family'] == 'rhel'

  remote_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7' do
    source 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end

  package 'epel-release' do
    action :install
  end

  execute 'yum_makecache' do
    command '/bin/yum -y makecache'
  end

end

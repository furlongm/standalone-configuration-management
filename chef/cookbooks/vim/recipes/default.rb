case node['platform_family']
  when 'debian'
    package ['vim', 'vim-scripts'] do
      action :install
    end
  when 'rhel'
    package 'vim-enhanced' do
      action :install
    end
  end
  when 'suse'
    package ['vim', 'vim-data'] do
      action :install
    end
  end
end

cookbook_file 'vimrc.local' do
  path '/etc/vim/vimrc.local'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

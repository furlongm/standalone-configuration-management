class vim {

  $vim = $::osfamily ? {
    'RedHat' => 'vim-enhanced',
    default  => 'vim',
  }

  package { $vim:
    ensure => installed,
  }

  if $::osfamily == 'Debian' {
    package { 'vim-scripts':
      ensure => installed,
    }
  }

  if $::osfamily == 'Suse' {
    package { 'vim-data':
      ensure => installed,
    }
  }

  file { '/etc/vim':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }    

  file { '/etc/vim/vimrc.local':
    source  => 'puppet:///modules/vim/vimrc.local',
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['etc/vim'],
  }
}

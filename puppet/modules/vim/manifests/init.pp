class vim {

  $vim = $facts['os']['family'] ? {
    'RedHat' => 'vim-enhanced',
    default  => 'vim',
  }

  package { $vim:
    ensure => installed,
  }

  if $facts['os']['family'] == 'Debian' {
    package { 'vim-scripts':
      ensure => installed,
    }
  }

  if $facts['os']['family'] == 'Suse' {
    package { 'vim-data':
      ensure => installed,
    }

    file { '/etc/vimrc':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/vim/vimrc.Suse',
    }
  }

  if $facts['os']['family'] == 'RedHat' {
    file { '/etc/vimrc':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/vim/vimrc.RedHat',
    }
  }

  file { '/etc/vim':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/vim/vimrc.local':
    ensure  => present,
    source  => 'puppet:///modules/vim/vimrc.local',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/vim'],
  }
}

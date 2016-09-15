class ssh {

  $openssh_service = $::osfamily ? {
    'Debian' => 'ssh',
    default  => 'sshd',
  }

  $openssh_package = $::osfamily ? {
    'Suse'   => 'openssh',
    default => 'openssh-server',
  }

  package { $openssh_package:
    ensure => installed,
  }

  file { '/etc/ssh/sshrc':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/ssh/sshrc',
  }

  service { $openssh_service:
    ensure  => running,
    require => [Package[$openssh_package], File['/etc/ssh/sshrc']],
  }
}

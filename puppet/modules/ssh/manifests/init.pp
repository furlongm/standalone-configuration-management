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

  service { $openssh_service:
    ensure  => running,
    require => Package[$openssh_package],
  }
}

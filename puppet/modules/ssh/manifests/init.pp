class ssh {

  $openssh_service = $::osfamily ? {
    'Debian' => 'ssh',
    default  => 'sshd',
  }

  $openssh_server = $::osfamily ? {
    'Suse'   => 'openssh',
    default => 'openssh-server',
  }

  package { $openssh_server:
    ensure => installed,
  }

  service { $openssh_service:
    ensure  => running,
    require => Package[$openssh_server],
  }
}

class ssh {

  $openssh_service = $facts['os']['family'] ? {
    'Debian' => 'ssh',
    default  => 'sshd',
  }

  $openssh_package = $facts['os']['family'] ? {
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

  if $facts['virtual'] != 'docker' {
    service { $openssh_service:
      ensure  => running,
      require => [Package[$openssh_package],
                  File['/etc/ssh/sshrc']],
    }
  }
}

class haveged {

  package { 'haveged':
    ensure => installed,
  }

  if $facts['virtual'] != 'docker' {
    service { 'haveged':
      ensure  => running,
      enable  => true,
      require => Package['haveged'],
    }
  }
}

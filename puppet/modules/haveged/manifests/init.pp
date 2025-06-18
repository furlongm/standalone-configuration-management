class haveged {

  package { 'haveged':
    ensure => installed,
  }

  if $facts['containerized'] == 'false' {
    service { 'haveged':
      ensure  => running,
      enable  => true,
      require => Package['haveged'],
    }
  }
}

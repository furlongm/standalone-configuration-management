class haveged {

  package { 'haveged':
    ensure => installed,
  }

  service { 'haveged':
    ensure  => running,
    enable  => true,
    require => Package['haveged'],
  }
}

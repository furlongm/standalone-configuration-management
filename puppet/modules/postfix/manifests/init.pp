class postfix {

  package { 'postfix':
    ensure => installed,
  }

  $mailx = $::osfamily ? {
    'Debian' => 'bsd-mailx',
    default  => 'mailx',
  }

  package { $mailx:
    ensure => installed,
  }

  service { 'postfix':
    ensure  => running,
    enable  => true,
    require => Package['postfix'],
  }

  file { '/etc/postfix/main.cf':
    content => template('postfix/main.cf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Package['postfix'],
    notify  => Service['postfix'],
  }
}

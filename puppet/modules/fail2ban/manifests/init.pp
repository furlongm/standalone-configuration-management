class fail2ban {

  package { 'fail2ban':
    ensure => installed,
  }

  service { 'fail2ban':
    ensure  => running,
    enable  => true,
    require => [Package['fail2ban'],
                  File['/etc/fail2ban/jail.local',
                    '/etc/fail2ban/fail2ban.local']],
  }

  file { '/etc/fail2ban/jail.local':
    content => template('fail2ban/jail.local.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['fail2ban'],
    notify  => Service['fail2ban'],
  }

  file { '/etc/fail2ban/fail2ban.local':
    source  => 'puppet:///modules/fail2ban/fail2ban.local',
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['fail2ban'],
    notify  => Service['fail2ban'],
  }
}

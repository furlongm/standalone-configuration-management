class postfix(
  $root_alias='admin@example.com'
) {

  $mailx = $facts['os']['family'] ? {
    'Suse' => 'mailx',
    default  => 's-nail',
  }

  package { $mailx:
    ensure => installed,
  }

  $exim = $facts['os']['family'] ? {
    'Debian' => 'exim4',
    default  => 'exim',
  }

  package { 'postfix':
    ensure  => installed,
  }

  package { $exim:
    ensure => absent,
  }

  if ($facts['os']['family'] == 'Debian') or ($facts['os']['name'] == 'Fedora') {
    package { 'postfix-lmdb':
      ensure => installed,
    }
  }

  if $facts['virtual'] != 'docker' {
    service { 'postfix':
      ensure    => running,
      enable    => true,
      require   => Package['postfix'],
      subscribe => [File['/etc/postfix/main.cf'],
                    Exec['newaliases']],
    }
  }

  file { '/etc/postfix/main.cf':
    content => template('postfix/main.cf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['postfix'],
  }

  mailalias { 'root_alias':
    ensure    => present,
    name      => 'root',
    recipient => $root_alias,
    target    => '/etc/aliases'
  }

  exec { 'newaliases':
    command     => '/usr/bin/newaliases',
    refreshonly => true,
    subscribe   => Mailalias['root_alias'],
  }
}

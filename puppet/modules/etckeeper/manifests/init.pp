class etckeeper {

  require repos

  package { 'etckeeper':
    ensure => installed,
  }

  exec { 'etckeeper-init':
    path      => '/usr/bin:/usr/sbin:/bin:/sbin',
    command   => 'etckeeper init',
    subscribe => Package['etckeeper'],
    unless    => 'test -d /etc/.git',
  }

  file { '/etc/.git/config':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('etckeeper/gitconfig.erb'),
    require => Exec[etckeeper-init],
  }
}

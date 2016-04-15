class etckeeper {

  $etckeeper_pkgs = ['etckeeper', 'git']

  package { $etckeeper_pkgs:
    ensure => installed,
  }

  exec { 'etckeeper-init':
    path      => '/usr/bin:/usr/sbin:/bin:/sbin',
    command   => 'etckeeper init',
    subscribe => Package[$etckeeper_pkgs],
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

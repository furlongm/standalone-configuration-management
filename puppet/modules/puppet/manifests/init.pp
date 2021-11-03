class puppet {

  file { '/etc/puppet':
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    ensure => directory,
  }

  file { '/etc/puppet/puppet.conf':
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    source => 'puppet:///modules/puppet/puppet.conf',
  }
}

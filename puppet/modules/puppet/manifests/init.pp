class puppet {

  file { '/etc/puppet/puppet.conf':
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    source => 'puppet:///modules/puppet/puppet.conf',
  }

  file { '/etc/puppet/modules':
    ensure => 'link',
    target => '/srv/puppet/modules',
  }

  file { '/etc/puppet/manifests':
    ensure => 'link',
    target => '/srv/puppet/manifests',
  }
}

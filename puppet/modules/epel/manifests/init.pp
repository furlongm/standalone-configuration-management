class epel {

  if $::osfamily == 'RedHat' {

    $epel_release_uri = $::operatingsystem ? {
      'CentOS' => 'epel-release',
      default  => 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm',
    }

    package { $epel_release_uri:
      ensure  => installed,
      notify  => Exec['yum_makecache'],
    }

    exec { 'yum_makecache':
      command     => '/usr/bin/yum -y makecache',
      refreshonly => true,
    }
  }
}

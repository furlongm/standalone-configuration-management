class epel {

  if $::osfamily == 'RedHat' {

    $epel_release_uri = $::operatingsystem ? {
      'CentOS' => 'epel-release',
      default  => 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm',
    }

    package { $epel_release_uri:
      ensure => installed,
      notify => Exec['dnf_makecache'],
    }

    exec { 'dnf_makecache':
      command     => '/usr/bin/dnf -y makecache',
      refreshonly => true,
    }
  }
}

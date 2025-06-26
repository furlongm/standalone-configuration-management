class epel {

  if $facts['os']['family'] == 'RedHat' {

    $epel_release_uri = $facts['os']['name']? {
      'CentOS' => 'epel-release',
      default  => 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm',
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

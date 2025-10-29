class repos {

  if $facts['os']['family'] == 'RedHat' and $facts['os']['name'] != 'Fedora' {

    $os_release_major = $facts['os']['release']['major']

    $epel_release_uri = $facts['os']['name']? {
      'Rocky'  => 'epel-release',
      default  => "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${os_release_major}.noarch.rpm",
    }

    package { $epel_release_uri:
      ensure => installed,
      notify => Exec['dnf_makecache'],
    }

    exec { 'dnf_makecache':
      command     => '/usr/bin/dnf -y makecache',
      refreshonly => true,
    }

  } elsif $facts['os']['family'] == 'Suse' {

    exec { 'enable_non_oss_repo':
      command => '/usr/bin/zypper modifyrepo --enable "openSUSE:repo-non-oss"',
      unless  => '/usr/bin/zypper repos --enabled | /usr/bin/grep -q "openSUSE:repo-non-oss"',
    }
  }
}

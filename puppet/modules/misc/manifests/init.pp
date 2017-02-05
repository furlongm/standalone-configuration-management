class misc {

  $misc_packages = [
    'htop',
    'tree',
    'git',
    'strace',
    'mlocate',
    'diffstat',
    'bash-completion',
    'pwgen',
    'lsof',
    'multitail',
  ]

  package { $misc_packages:
    ensure => installed,
  }

  if $::osfamily == 'Debian' {

    $debian_packages = [
      'apt-transport-https',
      'debian-goodies',
    ]

    package { $debian_packages:
      ensure => installed,
    }

  }
}

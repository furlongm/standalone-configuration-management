class misc {

  $misc_packages = [
    'htop',
    'tree',
    'git',
    'strace',
    'diffstat',
    'bash-completion',
    'pwgen',
    'lsof',
    'plocate',
  ]

  package { $misc_packages:
    ensure => installed,
  }

  if $facts['os']['family'] == 'Debian' {
    $debian_packages = [
      'apt-transport-https',
      'debian-goodies',
    ]

    package { $debian_packages:
      ensure => installed,
    }
  }
}

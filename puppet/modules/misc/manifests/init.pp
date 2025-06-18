class misc {

  if $facts['os']['family'] == 'Debian' or $facts['os']['distro']['id'] == 'Fedora' {
    $locate = 'plocate'
  } else {
    $locate = 'mlocate'
  }

  $misc_packages = [
    'htop',
    'tree',
    'git',
    'strace',
    'diffstat',
    'bash-completion',
    'pwgen',
    'lsof',
    'multitail',
    $locate,
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

class misc {

  $locate = $facts['os']['family'] ? {
    'Fedora' => 'plocate',
    'Debian' => 'plocate',
    default  => 'mlocate',
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

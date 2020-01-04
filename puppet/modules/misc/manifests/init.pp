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

  if $::osfamily != 'RedHat' {
    $misc_packages = $misc_packages + 'bmon'
  }

  if $::osfamily == 'Debian' {
    $misc_packages = $misc_packages + [
      'apt-transport-https',
      'debian-goodies',
    ]
  }

  package { $misc_packages:
    ensure => installed,
  }
}

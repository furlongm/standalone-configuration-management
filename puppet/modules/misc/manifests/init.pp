class misc {

  require epel

  $misc_packages = ['htop', 'tree', 'git', 'strace', 'mlocate', 'diffstat', 'bash-completion', 'pwgen']

  package { $misc_packages:
    ensure => installed,
  }

  if $::osfamily == 'Debian' {
    package { 'debian-goodies':
      ensure => installed,
    }
  }
}

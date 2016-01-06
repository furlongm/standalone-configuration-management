class net {

  $net_packages = ['ethtool', 'tcpdump', 'nmap', 'telnet', 'iftop', 'whois', 'wget']

  package { $net_packages:
    ensure => installed,
  }

  $bindutils = $::osfamily ? {
    'Debian' => 'dnsutils',
    default  => 'bind-utils',
  }

  package { $bindutils:
    ensure => installed,
  }
}

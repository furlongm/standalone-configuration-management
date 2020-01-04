class net {

  $net_packages = [
    'ethtool',
    'tcpdump',
    'nmap',
    'telnet',
    'iftop',
    'whois',
    'wget',
    'ipset',
    'nload',
    'iperf3',
    'bmon',
  ]

  package { $net_packages:
    ensure => installed,
  }

  $bindutils = $::osfamily ? {
    'Debian' => 'dnsutils',
    default  => 'bind-utils',
  }

  $iperf = $::osfamily ? {
    'Suse'  => 'iperf',
    default => 'iperf3',
  }

  package { [$bindutils, $iperf]:
    ensure => installed,
  }
}

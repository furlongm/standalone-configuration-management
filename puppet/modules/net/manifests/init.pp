class net {

  $bindutils = $facts['os']['family'] ? {
    'Debian' => 'bind9-dnsutils',
    default  => 'bind-utils',
  }

  $iperf = $facts['os']['family'] ? {
    'Suse'  => 'iperf',
    default => 'iperf3',
  }

  $net_packages = [
    'ethtool',
    'tcpdump',
    'nmap',
    'telnet',
    'iftop',
    'whois',
    'wget2',
    'ipset',
    'nload',
    'bmon',
    $bindutils,
    $iperf,
  ]

  package { $net_packages:
    ensure => installed,
  }
}

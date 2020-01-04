class net {

  $bindutils = $::osfamily ? {
    'Debian' => 'dnsutils',
    default  => 'bind-utils',
  }

  $iperf = $::osfamily ? {
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
    'wget',
    'ipset',
    'nload',
    $bindutils,
    $iperf,
  ]

  package { $net_packages:
    ensure => installed,
  }

  if $::osfamily != 'RedHat' {
    package { 'bmon':
      ensure => installed,
    }
  }
}

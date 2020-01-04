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
  ]

  $bindutils = $::osfamily ? {
    'Debian' => 'dnsutils',
    default  => 'bind-utils',
  }

  $iperf = $::osfamily ? {
    'Suse'  => 'iperf',
    default => 'iperf3',
  }

  $net_packages = $net_packages + [$bindutils, $iperf]

  if $::osfamily != 'RedHat' {
    $net_packages = $net_packages + 'bmon'
  }

  package { $net_packages:
    ensure => installed,
  }
}

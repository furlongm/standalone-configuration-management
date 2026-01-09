netpkgs:
  pkg.installed:
    - pkgs:
      - ethtool
      - tcpdump
      - nmap
      - telnet
      - iftop
      - whois
      - wget2
      - ipset
      - nload
      - {{ salt['pillar.get']('pkgs:bind-utils') }}
      - {{ salt['pillar.get']('pkgs:iperf') }}

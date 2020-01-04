netpkgs:
  pkg.installed:
    - pkgs:
      - ethtool
      - tcpdump
      - nmap
      - telnet
      - iftop
      - whois
      - wget
      - ipset
      - nload
      - bmon
      - {{ salt['pillar.get']('pkgs:bind-utils') }}
      - {{ salt['pillar.get']('pkgs:iperf') }}

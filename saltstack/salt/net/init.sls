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
      - iperf
      - ipset
      - nload
      - bmon
      - {{ salt['pillar.get']('pkgs:bind-utils') }}

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
      - iperf3
      - bmon
      - {{ salt['pillar.get']('pkgs:bind-utils') }}

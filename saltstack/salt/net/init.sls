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
      - {{ salt['pillar.get']('pkgs:bind-utils') }}
      - {{ salt['pillar.get']('pkgs:iperf') }}

{% if grains['os_family'] != 'RedHat' %}

bmon:
  pkg.installed

{% endif %

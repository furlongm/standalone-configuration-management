ethtool:
  pkg.installed

tcpdump:
  pkg.installed

nmap:
  pkg.installed

telnet:
  pkg.installed

iftop:
  pkg.installed

bind-utils:
  pkg:
    - installed
    - name: {{ pillar['pkgs']['bind-utils'] }}


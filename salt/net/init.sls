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

whois:
  pkg.installed

bind-utils:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('pkgs:bind-utils') }}

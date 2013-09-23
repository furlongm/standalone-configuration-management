htop:
  pkg.installed

tree:
  pkg.installed

git:
  pkg.installed

strace:
  pkg.installed

locate:
  pkg:
    - installed
    - name: {{ pillar['pkgs']['locate'] }}

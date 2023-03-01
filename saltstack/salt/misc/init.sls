miscpkgs:
  pkg.installed:
    - pkgs:
      - htop
      - tree
      - git
      - strace
      - diffstat
      - bash-completion
      - pwgen
      - lsof
      - multitail
      - {{ salt['pillar.get']('pkgs:locate') }}

{% if grains['os_family'] == 'Debian' %}

debian-goodies:
  pkg.installed

apt-transport-https:
  pkg.installed

{% endif %}

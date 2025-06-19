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
      - plocate

{% if grains['os_family'] == 'Debian' %}

debian-goodies:
  pkg.installed

apt-transport-https:
  pkg.installed

{% endif %}

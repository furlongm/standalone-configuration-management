miscpkgs:
  pkg.installed:
    - pkgs:
      - htop
      - tree
      - git
      - strace
      - mlocate
      - diffstat
      - bash-completion
      - pwgen
      - lsof

{% if grains['os_family'] != 'RedHat' %}

multitail:
  pkg.installed

{% endif %}

{% if grains['os_family'] == 'Debian' %}

debian-goodies:
  pkg.installed

apt-transport-https:
  pkg.installed

{% endif %}

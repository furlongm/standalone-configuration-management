htop:
  pkg.installed

tree:
  pkg.installed

git:
  pkg.installed

strace:
  pkg.installed

mlocate:
  pkg.installed

diffstat:
  pkg.installed

bash-completion:
  pkg.installed

pwgen:
  pkg.installed

lsof:
  pkg.installed

multitail:
  pkg.installed

{% if grains['os_family'] == 'Debian' %}

debian-goodies:
  pkg.installed

{% endif %}

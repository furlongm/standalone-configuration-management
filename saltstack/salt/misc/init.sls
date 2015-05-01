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

{% if grains['os_family'] == 'Debian' %}
debian-goodies:
  pkg:
    - installed
{% endif %}

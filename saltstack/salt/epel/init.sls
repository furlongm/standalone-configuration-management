{% if grains['os_family'] == 'RedHat' and grains['os'] != 'Fedora' %}

epel-release:
  pkg.installed:
    - source: https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    - onchanges:
      - cmd.run dnf -y makecache

{% endif %}

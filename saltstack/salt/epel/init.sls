{% if grains['os_family'] == 'RedHat' and grains['os'] != 'Fedora' %}

dnf -y makecache:
  cmd.run:
    - onchanges:
      - pkg: epel-release

epel-release:
  pkg.installed:
    - source: https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

{% endif %}

{% if grains['os_family'] == 'RedHat' and grains['os'] != 'Fedora' %}

dnf -y makecache:
  cmd.run:
    - onchanges:
      - pkg: epel-release

epel-release:
  pkg.installed:
    {% if grains['os'] == 'Rocky' %}
    - name: epel-release
    {% else %}
    - source: https://dl.fedoraproject.org/pub/epel/epel-release-latest-{{ grains['osmajorrelease'] }}.noarch.rpm
    {% endif %}

{% endif %}

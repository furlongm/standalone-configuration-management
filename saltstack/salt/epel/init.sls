{% if grains['os_family'] == 'RedHat' %}

epel-release:
  pkg.installed:
    - source: https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    - on_changes:
      - cmd.run dnf -y makecache

{% endif %}

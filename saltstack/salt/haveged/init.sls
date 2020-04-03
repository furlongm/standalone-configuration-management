haveged:
  pkg:
    - installed
{% if not salt['grains.get']('virtual_subtype') or grains['virtual_subtype'] != 'Docker' %}
  service:
    - running
    - enable: True
{% endif %}

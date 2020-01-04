haveged:
  pkg:
    - installed
{% if grains['virtual_subtype'] != 'Docker' %}
  service:
    - running
    - enable: True
{% endif %}

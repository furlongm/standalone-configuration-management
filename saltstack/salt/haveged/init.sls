haveged:
  pkg:
    - installed
{% if grains['virtual'] != 'container' %}
  service:
    - running
    - enable: True
{% endif %}

haveged:
  pkg:
    - installed
{% if not salt['pillar.get']('containerized') %}
  service:
    - running
    - enable: True
{% endif %}

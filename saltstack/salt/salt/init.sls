{% if grains['virtual'] != 'container' %}
salt-minion:
  service:
    - dead
    - enable: False
    - watch:
      - file: /etc/salt/minion.d/standalone.conf
{% endif %}

/etc/salt/minion.d/standalone.conf:
  file.managed:
    - source: salt://salt/files/standalone.conf
    - user: root
    - group: root
    - mode: '0640'

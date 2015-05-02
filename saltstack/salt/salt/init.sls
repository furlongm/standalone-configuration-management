salt-minion:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/salt/minion.d/standalone.conf

/etc/salt/minion.d/standalone.conf:
  file.managed:
    - source: salt://salt/standalone.conf
    - user: root
    - group: root
    - mode: '0640'

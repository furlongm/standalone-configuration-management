salt-minion:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/salt/minion.d/standalone

/etc/salt/minion.d/standalone:
  file.managed:
    - source: salt://salt/standalone
    - user: root
    - group: root
    - mode: '0640'

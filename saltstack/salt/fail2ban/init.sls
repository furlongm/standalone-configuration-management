fail2ban:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/fail2ban/fail2ban.local
      - file: /etc/fail2ban/jail.local

/etc/fail2ban/jail.local:
  file.managed:
    - source: salt://fail2ban/files/jail.local.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: fail2ban

/etc/fail2ban/fail2ban.local:
  file.managed:
    - source: salt://fail2ban/fail2ban.local
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: fail2ban

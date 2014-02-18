fail2ban:
  pkg.installed
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/fail2ban/fail2ban.conf
      - file: /etc/fail2ban/jail.conf

/etc/fail2ban/jail.conf:
  file.managed:
    - source: salt://fail2ban/jail.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: fail2ban

/etc/fail2ban/fail2ban.conf:
  file.managed:
    - source: salt://fail2ban/fail2ban.conf
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: fail2ban

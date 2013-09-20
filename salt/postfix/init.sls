postfix:
  pkg:
    - installed
  service:
    - running
    - watch:
      - file: /etc/postfix/main.cf
      - cmd: newaliases

/etc/postfix/main.cf:
  file.managed:
    - source: salt://postfix/main.cf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: postfix

/etc/aliases:
  file.managed:
    - source: salt://postfix/aliases.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: postfix

/etc/mailname:
  file.managed:
    - source: salt://postfix/mailname.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: postfix

newaliases:
  cmd.wait:
    - name: /usr/bin/newaliases
    - watch:
      - file: /etc/aliases
    - require:
      - file: /etc/mailname

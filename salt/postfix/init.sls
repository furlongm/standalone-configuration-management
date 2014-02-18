postfix:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/postfix/main.cf
      - cmd: newaliases

mailx:
  pkg:
    - installed
    - name: {{ pillar['pkgs']['mailx'] }}

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

newaliases:
  cmd.wait:
    - name: /usr/bin/newaliases
    - watch:
      - file: /etc/aliases

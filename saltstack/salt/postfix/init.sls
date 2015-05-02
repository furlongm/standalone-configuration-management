postfix:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/postfix/main.cf

mailx:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('pkgs:mailx') }}

/etc/postfix/main.cf:
  file.managed:
    - source: salt://postfix/main.cf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: postfix

postfix:
  pkg:
    - installed
    - require:
      - pkg: exim
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/postfix/main.cf

mailx:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('pkgs:mailx') }}

exim:
  pkg:
    - removed
    - name: {{ salt['pillar.get']('pkgs:exim') }}


/etc/postfix/main.cf:
  file.managed:
    - source: salt://postfix/main.cf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: postfix

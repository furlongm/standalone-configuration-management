etckeeper:
  pkg.installed

etckeeper init:
  cmd.run:
    - creates: /etc/.git
    - require:
      - pkg: etckeeper

/etc/.git/config:
  file.managed:
    - source: salt://etckeeper/files/gitconfig.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - cmd: etckeeper init

openssh-server:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('pkgs:openssh-server') }}

/etc/ssh/sshrc:
  file.managed:
    - source: salt://ssh/files/sshrc
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: openssh-server

ssh:
  service:
    - name: {{ salt['pillar.get']('svcs:ssh') }}
    - running
    - enable: True
    - watch:
      - pkg: openssh-server
    - require:
      - pkg: openssh-server
      - file: /etc/ssh/sshrc

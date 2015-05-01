openssh-server:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('pkgs:openssh-server') }}

ssh:
  service:
    - name: {{ salt['pillar.get']('svcs:ssh') }}
    - running
    - enable: True
    - watch:
      - pkg: openssh-server
    - require:
      - pkg: openssh-server

/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

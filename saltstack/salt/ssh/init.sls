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

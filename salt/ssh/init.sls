openssh-server:
  pkg.installed

ssh:
  service:
    - name: {{ pillar['svcs']['ssh'] }}
    - running
    - enable: True
    - watch:
      - pkg: openssh-server
    - require:
      - pkg: openssh-server

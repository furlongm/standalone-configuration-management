openssh-server:
  pkg:
    - installed
    - name: {{ pillar['pkgs']['openssh-server'] }}

ssh:
  service:
    - name: {{ pillar['svcs']['ssh'] }}
    - running
    - enable: True
    - watch:
      - pkg: openssh-server
    - require:
      - pkg: openssh-server

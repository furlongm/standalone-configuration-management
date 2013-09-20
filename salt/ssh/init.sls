openssh-server:
  pkg.installed

ssh:
  service.running:
    - enable: True
    - watch:
      - pkg: openssh-server

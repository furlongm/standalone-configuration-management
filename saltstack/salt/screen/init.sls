screen:
  pkg.installed

/etc/screenrc:
  file.managed:
    - source: salt://screen/screenrc
    - user: root
    - group: root
    - mode: '0644'

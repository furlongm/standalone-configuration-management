vim:
  pkg:
    - installed
    - name: {{ pillar['pkgs']['vim'] }}

vim-scripts:
  pkg.installed

/etc/vim/vimrc.local:
  file.managed:
    - source: salt://vim/vimrc.local
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: vim

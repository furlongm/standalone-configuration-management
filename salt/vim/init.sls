vim:
  pkg:
    - installed
    - name: {{ pillar['pkgs']['vim'] }}

{% if grains['os'] == 'Debian'%}
vim-scripts:
  pkg.installed
{% endif %}

/etc/vim/vimrc.local:
  file.managed:
    - source: salt://vim/vimrc.local
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: vim

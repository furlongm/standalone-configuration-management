vim:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('pkgs:vim') }}

{% if grains['os_family'] == 'Debian' %}
vim-scripts:
  pkg:
    - installed
{% endif %}

{% if grains['os_family'] == 'Suse' %}
vim-data:
  pkg:
    - installed
{% endif %}

/etc/vim:
  file.directory:
    - user: root
    - group: root
    - mode: '0755'

/etc/vim/vimrc.local:
  file.managed:
    - source: salt://vim/vimrc.local
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: /etc/vim

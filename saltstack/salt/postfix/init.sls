postfix:
  pkg:
    - installed
    - require:
      - pkg: exim
{% if not salt['grains.get']('virtual_subtype') or grains['virtual_subtype'] != 'Docker' %}
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/postfix/main.cf
{% endif %}

{% if grains['os_family'] == 'Debian' or grains['os'] == 'Fedora' %}
postfix-lmdb:
  pkg:
    - installed
{% endif %}

mailx:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('pkgs:mailx') }}

exim:
  pkg:
    - removed
    - name: {{ salt['pillar.get']('pkgs:exim') }}

/etc/postfix/main.cf:
  file.managed:
    - source: salt://postfix/files/main.cf.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: postfix

{% if salt['pillar.get']('root_alias') %}
root:
  alias.present:
    - target: {{ salt['pillar.get']('root_alias') }}
{% endif %}

newaliases:
  cmd.run

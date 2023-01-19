locales:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('pkgs:locales') }}

{% if grains['os_family'] == 'Debian' %}

locale-gen:
  cmd.run:
    - onchanges:
      - file: locale.gen

locale.gen:
  file.managed:
    - name: /etc/locale.gen
    - contents: "{{ salt['pillar.get']('locale:locale') }} UTF-8"
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: locales

{% endif %}

environment:
  file.managed:
    - name: /etc/environment
    - source: salt://locale/files/environment.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: locales

{% if not salt['grains.get']('virtual_subtype') or grains['virtual_subtype'] != 'Docker' %}

localectl set-locale LANG={{ salt['pillar.get']('locale:locale') }}:
  cmd.run:
    - unless:
      - localectl status | grep {{ salt['pillar.get']('locale:locale') }}
    - require:
      - pkg: locales

timedatectl set-timezone {{ salt['pillar.get']('locale:timezone') }}:
  cmd.run:
    - unless:
      - timedatectl status | grep {{ salt['pillar.get']('locale:timezone') }}

{% endif %}

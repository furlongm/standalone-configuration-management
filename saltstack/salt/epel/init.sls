{% if grains['os_family'] == 'RedHat' %}

install_pubkey_epel:
  file.managed:
    - name: /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
    - source: http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
    - source_hash: md5=58fa8ae27c89f37b08429f04fd4a88cc

epel-release:
  pkg.installed:
    - require:
      - file: install_pubkey_epel
    - source: https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    - on_changes:
      - cmd.run yum -y makecache

{% endif %}

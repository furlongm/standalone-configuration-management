pkgs:
  {% if grains['os_family'] == 'RedHat' %}
  openssh-server: openssh-server
  apache: httpd
  vim: vim-enhanced
  locate: mlocate
  mailx: bsd-mailx
  {% elif grains['os_family'] == 'Debian' %}
  openssh-server: openssh-server
  apache: apache2
  vim: vim
  locate: mlocate
  mailx: bsd-mailx
  {% elif grains['os_family'] == 'Suse' %}
  openssh-server: openssh
  apache: apache2
  vim: vim-enhanced
  locate: findutils-locate
  mailx: mailx
  {% endif %}

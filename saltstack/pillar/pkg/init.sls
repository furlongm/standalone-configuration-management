pkgs:
  {% if grains['os_family'] == 'RedHat' %}
  openssh-server: openssh-server
  apache: httpd
  vim: vim-enhanced
  mailx: mailx
  exim: exim
  bind-utils: bind-utils
  {% elif grains['os_family'] == 'Debian' %}
  openssh-server: openssh-server
  apache: apache2
  vim: vim
  mailx: bsd-mailx
  exim: exim4
  bind-utils: dnsutils
  {% elif grains['os_family'] == 'Suse' %}
  openssh-server: openssh
  apache: apache2
  vim: vim
  mailx: mailx
  exim: exim
  bind-utils: bind-utils
  {% endif %}

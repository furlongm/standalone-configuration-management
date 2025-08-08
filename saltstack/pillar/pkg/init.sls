pkgs:
  {% if grains['os_family'] == 'RedHat' %}
  openssh-server: openssh-server
  apache: httpd
  vim: vim-enhanced
  mailx: s-nail
  exim: exim
  bind-utils: bind-utils
  iperf: iperf3
  locales: glibc-common
  {% elif grains['os_family'] == 'Debian' %}
  openssh-server: openssh-server
  apache: apache2
  vim: vim
  mailx: s-nail
  exim: exim4
  bind-utils: bind9-dnsutils
  iperf: iperf3
  locales: locales
  {% elif grains['os_family'] == 'Suse' %}
  openssh-server: openssh
  apache: apache2
  vim: vim
  mailx: mailx
  exim: exim
  bind-utils: bind-utils
  iperf: iperf
  locales: glibc-locale
  {% endif %}

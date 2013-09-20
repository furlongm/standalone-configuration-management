svcs:
  {% if grains['os_family'] == 'RedHat' %}
  ssh: sshd
  {% elif grains['os_family'] == 'Debian' %}
  ssh: ssh
  {% endif %}

svcs:
  {% if grains['os_family'] == 'RedHat' %}
  ssh: sshd
  {% elif grains['os_family'] == 'Debian' %}
  ssh: ssh
  {% elif grains['os_family'] == 'Suse' %}
  ssh: sshd
  {% endif %}

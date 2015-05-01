base:
  '*':
    - vim
    - net
    - screen
    - ssh
    - postfix
    - misc
    - fail2ban

file_client: local

file_roots:
  base:
    - /srv/salt

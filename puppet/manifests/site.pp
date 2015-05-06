node default {

  include vim
  include net
  include screen
  include ssh
  include postfix
  include misc
  include fail2ban

  mailalias { 'root_alias':
    ensure    => present,
    name      => 'root',
    recipient => 'admin@example.com',
    target    => '/etc/aliases'
  }
}

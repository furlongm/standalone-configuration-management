node default {

  Package {
    allow_virtual => true
  }

  include vim
  include net
  include screen
  include ssh
  include misc
  include fail2ban
  include puppet

  class { 'postfix':
    root_alias => 'admin@example.com',
  }

}

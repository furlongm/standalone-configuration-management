node default {

  Package {
    allow_virtual => true
  }

  include puppet
  include etckeeper
  include misc
  include net
  include screen
  include ssh
  include fail2ban
  include haveged
  include vim

  class { 'postfix':
    root_alias => 'admin@example.com',
  }

}

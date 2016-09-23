node default {

  Package {
    allow_virtual => true
  }

  stage { ['pre', 'post']: }

  Stage['pre'] -> Stage['main'] -> Stage['post']

  class { 'epel':
    stage => 'pre',
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

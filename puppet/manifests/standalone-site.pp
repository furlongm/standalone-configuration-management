node default {

  Package {
    allow_virtual => true
  }

  stage { ['pre', 'post']: }

  Stage['pre'] -> Stage['main'] -> Stage['post']

  class { 'repos':
    stage => 'pre',
  }

  include etckeeper
  include locale
  include misc
  include net
  include screen
  include ssh
  include fail2ban
  include haveged
  include vim
}

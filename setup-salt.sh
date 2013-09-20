#!/bin/bash

function usage() {
    echo "Usage:"
    echo "./$0 admin@example.com"
    echo "Substitute your email address to receive root email"
    exit 1
}

function vim_syntax_highlighting() {
  mkdir -p ~/.vim
  git clone https://github.com/saltstack/salt-vim.git /tmp/salt-vim.git
  cp -r /tmp/salt-vim.git/ftdetect /tmp/salt-vim.git/ftplugin /tmp/salt-vim.git/syntax  ~/.vim/
  rm -fr /tmp/salt-vim.git
}

function github_config() {
  git clone https://github.com/furlongm/salt-pillar /tmp/salt-pillar.git
  cp -r /tmp/salt-pillar.git/salt /srv
  cp -r /tmp/salt-pillar.git/pillar /srv
  rm -fr /tmp/salt-pillar.git
}

function main() {
  wget -O - http://bootstrap.saltstack.org | sudo sh
  github_config
  vim_syntax_highlighting
  sed -i -e "s/admin@example.com/${1}" /srv/pillar/postfix/init.sls
  salt-call --local state.highstate
}

if [ "${1}" == "" ] ; then
    usage
else
    main ${1}
fi

#!/bin/bash

function usage() {
    echo "Usage:"
    echo "./$0 admin@example.com"
    echo "This script needs to be run as root."
    echo "Substitute your email address as the first argument."
    echo "You also need to install git prior to running this script."
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
  wget -O - http://bootstrap.saltstack.org | sh
  github_config
  vim_syntax_highlighting
  sed -i -e "s/admin@example.com/${1}/" /srv/pillar/postfix/init.sls
  salt-call --local state.highstate
}

if [ "${1}" == "" ] ; then
    usage
else
    which git 1>/dev/null 2>&1 || usage
    euid=$(id -u)
    if [ "${euid}" !=  "0" ] ;  then usage ; fi
    main ${1}
fi

#!/bin/bash

usage() {
    echo "Usage: $0 -e EMAIL_ADDRESS (as root)"
    exit 1
}

install_deps() {
    if [ -f '/etc/debian_version' ] ; then
        pm="apt-get -y"
    elif [ -f '/etc/redhat-release' ] ; then
        pm="yum -y"
    elif [ -f '/etc/SuSE-release' ] ; then
        pm="zypper -n"
    fi
    $pm install git curl
}

install_vim_syntax_highlighting() {
  mkdir -p ~/.vim
  git clone https://github.com/saltstack/salt-vim.git /tmp/salt-vim.git
  cp -r /tmp/salt-vim.git/ftdetect /tmp/salt-vim.git/ftplugin /tmp/salt-vim.git/syntax  ~/.vim/
  rm -fr /tmp/salt-vim.git
}

get_config_from_github() {
  git clone https://github.com/furlongm/salt-pillar /tmp/salt-pillar.git
  cp -r /tmp/salt-pillar.git/salt /srv
  cp -r /tmp/salt-pillar.git/pillar /srv
  rm -fr /tmp/salt-pillar.git
}

main() {
  curl -L http://bootstrap.saltstack.org | sudo bash || exit 1
  get_config_from_github
  install_vim_syntax_highlighting
  sed -i -e "s/admin@example.com/${email}/" /srv/pillar/postfix/init.sls
  salt-call --local state.highstate
}

while getopts ":e:" opt ; do
  case ${opt} in
    e)
      email=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z ${email} || ${EUID} -ne 0 ]] ; then
    usage
else
    which git 1>/dev/null 2>&1 || install_deps
    which curl 1>/dev/null 2>&1 || install_deps
    main
fi

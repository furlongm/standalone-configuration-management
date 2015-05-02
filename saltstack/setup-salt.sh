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
  tmp_dir=$(mktemp -d)
  git clone https://github.com/furlongm/standalone-configuration-management ${tmp_dir}
  cp -r ${tmp_dir}/saltstack/salt /srv
  cp -r ${tmp_dir}/saltstack/pillar /srv
  rm -fr ${tmp_dir}
}

main() {
  curl -L http://bootstrap.saltstack.org | sudo bash || exit 1
  get_config_from_github
  install_vim_syntax_highlighting
  sed -i -e "s/admin@example.com/${email}/" /srv/salt/alias.sls
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

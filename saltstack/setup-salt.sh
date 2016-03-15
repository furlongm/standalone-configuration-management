#!/bin/bash

usage() {
    echo "Usage: $0 -e EMAIL_ADDRESS (as root)"
    exit 1
}

install_deps() {
    if [ -f '/etc/debian_version' ] ; then
        apt-get update
        pm="apt-get -y"
    elif [ -f '/etc/redhat-release' ] ; then
        pm="yum -y"
    elif [ -f '/etc/SuSE-release' ] ; then
        pm="zypper -n"
    fi
    $pm install git curl
}

install_salt() {
    curl -L http://bootstrap.saltstack.org | sudo bash || exit 1
}

install_vim_syntax_highlighting() {
    tmp_dir=$(mktemp -d)
    mkdir -p ~/.vim
    git clone https://github.com/saltstack/salt-vim.git ${tmp_dir}
    cp -r ${tmp_dir}/ftdetect ${tmp_dir}/ftplugin ${tmp_dir}/syntax  ~/.vim/
    rm -fr ${tmp_dir}
}

get_config_from_github() {
    tmp_dir=$(mktemp -d)
    git clone https://github.com/furlongm/standalone-configuration-management ${tmp_dir}
    cp -r ${tmp_dir}/saltstack/salt /srv
    cp -r ${tmp_dir}/saltstack/pillar /srv
    rm -fr ${tmp_dir}
}

main() {
    which salt-call 1>/dev/null 2>&1 || install_salt
    install_vim_syntax_highlighting
    if [ "${run_path}" != "." ] ; then
        run_path=/srv
        get_config_from_github
    fi
    sed -i -e "s/admin@example.com/${email}/" ${run_path}/salt/alias.sls
    salt-call --local --file-root ${run_path}/salt --pillar-root ${run_path}/pillar state.highstate
}

while getopts ":le:" opt ; do
    case ${opt} in
        e)
            email=${OPTARG}
            ;;
        l)
            run_path=.
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

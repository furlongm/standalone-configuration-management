#!/bin/bash

usage() {
    echo "Usage: $0 -e EMAIL_ADDRESS (as root)"
    exit 1
}

get_pm() {
    if [ -f '/etc/debian_version' ] ; then
        pm="apt-get -y"
        ${pm} update 
    elif [ -f '/etc/redhat-release' ] ; then
        pm="yum -y"
        ${pm} makecache
    elif [ -f '/etc/SuSE-release' ] ; then
        pm="zypper -n"
        ${pm} refresh
    fi
}

install_deps() {
    ${pm} install git curl
}

install_salt() {
    curl -L http://bootstrap.saltstack.org | sudo bash || exit 1
}

install_vim_syntax_highlighting() {
    if [ ! -z "${SUDO_UID}" ] ; then
        home=$(getent passwd ${SUDO_UID} | cut -d \: -f 6)
    else
        home=~
    fi
    for i in ftdetect ftplugin indent ; do
        if [ -f ${home}/.vim/${i}/sls.vim ] ; then
            return
        fi
    done
    tmp_dir=$(mktemp -d)
    mkdir -p ${home}/.vim
    git clone https://github.com/saltstack/salt-vim.git ${tmp_dir}
    cp -r ${tmp_dir}/ftdetect ${tmp_dir}/ftplugin ${tmp_dir}/syntax ${home}/.vim/
    if [ ! -z "${SUDO_UID}" ] ; then
        chown -R ${SUDO_UID}:${SUDO_GID} ${home}/.vim
    fi
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
    which git 1>/dev/null 2>&1 || install_deps
    which curl 1>/dev/null 2>&1 || install_deps
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
fi
main

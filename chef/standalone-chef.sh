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

install_chef() {
    curl -L https://www.chef.io/chef/install.sh | bash || exit 1
}

install_vim_syntax_highlighting() {
    if [ ! -z "${SUDO_UID}" ] ; then
        home=$(getent passwd ${SUDO_UID} | cut -d \: -f 6)
    else
        home=~
    fi
    if [ -f ${home}/.vim/syntax/chef.vim ] ; then
        return
    fi
    tmp_dir=$(mktemp -d)
    mkdir -p ${home}/.vim
    git clone https://github.com/vadv/vim-chef.git ${tmp_dir}
    cp -r ${tmp_dir}/* ${home}/.vim/
    if [ ! -z "${SUDO_UID}" ] ; then
        chown -R ${SUDO_UID}:${SUDO_GID} ${home}/.vim
    fi
    rm -fr ${tmp_dir}
}

get_config_from_github() {
    tmp_dir=$(mktemp -d)
    git clone https://github.com/furlongm/standalone-configuration-management ${tmp_dir}
    cp -r ${tmp_dir}/chef /srv
    rm -fr ${tmp_dir}
}

main() {
    get_pm
    which git 1>/dev/null 2>&1 || install_deps
    which curl 1>/dev/null 2>&1 || install_deps
    which chef-client 1>/dev/null 2>&1 || install_chef
    install_vim_syntax_highlighting
    if [ "${run_path}" != "." ] ; then
        run_path=/srv/chef
        get_config_from_github
        client_args="-c ${run_path}/client.rb"
    fi
    sed -i -e "s/root_mail_alias.*/root_mail_alias\": \"${email}\"/" ${run_path}/node.json
    chef-client -z -j ${run_path}/node.json ${client_args}
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

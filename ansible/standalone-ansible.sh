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

install_epel() {
    grep "Red Hat" /etc/redhat-release 2>&1 >/dev/null 
    if [ $? -eq 0 ] ; then
        epel_release_uri=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    else
        epel_release_uri=epel-release
    fi
}

install_deps() {
    ${pm} install git curl
}

install_ansible() {
    ${pm} install ansible
}

install_vim_syntax_highlighting() {
    if [ ! -z "${SUDO_UID}" ] ; then
        home=$(getent passwd ${SUDO_UID} | cut -d \: -f 6)
    else
        home=~
    fi
    for i in ftdetect ftplugin indent syntax ; do
        if [ -f ${home}/.vim/${i}/ansible.vim ] ; then
            return
        fi
    done
    tmp_dir=$(mktemp -d)
    mkdir -p ${home}/.vim
    git clone https://github.com/pearofducks/ansible-vim.git ${tmp_dir}
    cp -r ${tmp_dir}/* ${home}/.vim/
    if [ ! -z "${SUDO_UID}" ] ; then
        chown -R ${SUDO_UID}:${SUDO_GID} ${home}/.vim
    fi
    rm -fr ${tmp_dir}
}

get_config_from_github() {
    tmp_dir=$(mktemp -d)
    git clone https://github.com/furlongm/standalone-configuration-management ${tmp_dir}
    cp -r ${tmp_dir}/ansible /srv
    rm -fr ${tmp_dir}
}

main() {
    get_pm
    which yum 1>/dev/null 2>&1 && install_epel
    which git 1>/dev/null 2>&1 || install_deps
    which curl 1>/dev/null 2>&1 || install_deps
    which ansible 1>/dev/null 2>&1 || install_ansible
    install_vim_syntax_highlighting
    if [ "${run_path}" != "." ] ; then
        run_path=/srv/ansible
        get_config_from_github
    fi
    ansible --version
    ansible-playbook --diff -i ${run_path}/hosts ${run_path}/playbooks/site.yml -e "root_mail_alias=${email}" -e 'ansible_python_interpreter=/usr/bin/python3'
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

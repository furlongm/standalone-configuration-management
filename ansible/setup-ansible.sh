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

install_ansible() {
    pip install ansible
}

install_vim_syntax_highlighting() {
    for i in ftdetect ftplugin indent syntax ; do
        if [ -f ~/.vim/${i}/ansible.vim ] ; then
            return
        fi
    done
    tmp_dir=$(mktemp -d)
    mkdir -p ~/.vim
    git clone https://github.com/pearofducks/ansible-vim.git ${tmp_dir}
    cp -r ${tmp_dir}/* ~/.vim/
    rm -fr ${tmp_dir}
}

get_config_from_github() {
    tmp_dir=$(mktemp -d)
    git clone https://github.com/furlongm/standalone-configuration-management ${tmp_dir}
    cp -r ${tmp_dir}/ansible /srv
    rm -fr ${tmp_dir}
}

main() {
    which ansible 1>/dev/null 2>&1 || install_ansible
    install_vim_syntax_highlighting
    if [ "${run_path}" != "." ] ; then
        run_path=/srv/ansible
        get_config_from_github
    fi
    ansible-playbook --diff -i ${run_path}/hosts ${run_path}/playbooks/site.yml --extra-vars "root_mail_alias=${email}"
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

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
    if [ -f '/etc/debian_version' ] ; then
        pm="apt-get -y"
    elif [ -f '/etc/redhat-release' ] ; then
        pm="yum -y"
    elif [ -f '/etc/SuSE-release' ] ; then
        pm="zypper -n"
    fi
    $pm install ansible
}

install_vim_syntax_highlighting() {
    tmp_dir=$(mktemp -d)
    mkdir -p ~/.vim
    git clone https://github.com/chase/vim-ansible-yaml.git ${tmp_dir}
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
    if [ -z "${run_path}" ] ; then
        run_path=/srv/ansible
        get_config_from_github
    fi
    #sed -i -e "s/admin@example.com/${email}/" ${run_path}/manifests/site.pp
    ansible-playbook --diff -i ${run_path}/hosts ${run_path}/playbooks/site.yml
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

#!/bin/bash

usage() {
    echo "Usage: $0 -e EMAIL_ADDRESS [-m MAIL_RELAY_HOST] [-l] [-c] [-b branch] (as root)"
    exit 1
}

get_pm() {
    . /etc/os-release
    if [[ "${ID_LIKE}" =~ "debian" ]] || [[ "${ID}" == "debian" ]] ; then
        pm='apt -y'
        ${pm} update
    elif [[ "${ID_LIKE}" =~ "rhel" ]] || [[ "${ID_LIKE}" =~ "fedora" ]] || [[ "${ID}" == "fedora" ]] ; then
        pm='dnf -y'
        ${pm} makecache
        ${pm} install --allowerasing which findutils hostname libxcrypt-compat coreutils curl procps gawk
    elif [[ "${ID_LIKE}" =~ "suse" ]] ; then
        pm='zypper -n'
        ${pm} refresh
        ${pm} install gzip
    else
        echo "Error: no package manager found."
        exit 1
    fi
}

install_epel() {
    if [[ "${NAME}" =~ "Red Hat" ]] ; then
        epel_release_uri=https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
    else
        epel_release_uri=epel-release
    fi
    ${pm} install ${epel_release_uri}
    ${pm} makecache
}

install_deps() {
    ${pm} install git curl python3
}

install_ansible() {
    ${pm} install ansible
}

install_vim_syntax_highlighting() {
    if [ -n "${SUDO_UID}" ] ; then
        home=$(getent passwd "${SUDO_UID}" | cut -d: -f6)
    else
        home=~
    fi
    for i in ftdetect ftplugin indent syntax ; do
        if [ -f "${home}"/.vim/${i}/ansible.vim ] ; then
            return
        fi
    done
    tmp_dir=$(mktemp -d)
    mkdir -p "${home}"/.vim
    git clone https://github.com/pearofducks/ansible-vim "${tmp_dir}"
    cp -r "${tmp_dir}"/* "${home}"/.vim/
    if [ -n "${SUDO_UID}" ] ; then
        # shellcheck disable=SC2153
        chown -R "${SUDO_UID}":"${SUDO_GID}" "${home}"/.vim
    fi
    rm -fr "${tmp_dir}"
}

get_config_from_github() {
    tmp_dir=$(mktemp -d)
    git clone --branch "${branch}" https://github.com/furlongm/standalone-configuration-management "${tmp_dir}"
    cp -Lr "${tmp_dir}"/ansible /srv
    rm -fr "${tmp_dir}"
    run_path=/srv/ansible
}

get_local_config() {
    run_path=.
}

main() {
    get_pm
    which dnf 1>/dev/null 2>&1 && install_epel
    which git 1>/dev/null 2>&1 || install_deps
    which curl 1>/dev/null 2>&1 || install_deps
    which ansible 1>/dev/null 2>&1 || install_ansible
    install_vim_syntax_highlighting
    if [ -z "${run_locally}" ] ; then
        get_config_from_github
    else
        get_local_config
    fi
    set -e
    ansible --version
    ansible-playbook --diff -i ${run_path}/hosts ${run_path}/playbooks/site.yml -e "mail_relay=${mail_relay}" -e "root_alias=${root_alias}"
}

# defaults
branch=main

while getopts ":le:m:cb:" opt ; do
    case ${opt} in
        e)
            root_alias=${OPTARG}
            ;;
        l)
            run_locally=true
            ;;
        m)
            mail_relay=${OPTARG}
            ;;
        c)
            # noop on ansible as ansible is the only one that correctly detects being run in a container
            ;;
        b)
            branch=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z ${root_alias} || ${EUID} -ne 0 ]] ; then
    usage
fi
main

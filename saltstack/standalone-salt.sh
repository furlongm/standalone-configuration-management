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
        ${pm} install virt-what
    elif [[ "${ID_LIKE}" =~ "rhel" ]] || [[ "${ID_LIKE}" =~ "fedora" ]] || [[ "${ID}" == "fedora" ]] ; then
        pm='dnf -y'
        ${pm} makecache
        ${pm} install --allowerasing which findutils hostname libxcrypt-compat coreutils curl procps gawk virt-what systemd
    elif [[ "${ID_LIKE}" =~ "suse" ]] ; then
        pm='zypper -n'
        ${pm} refresh
        ${pm} install which gzip virt-what
    else
        echo "Error: no package manager found."
        exit 1
    fi
}

install_deps() {
    ${pm} install git curl
}

install_salt() {
    curl -L https://github.com/saltstack/salt-bootstrap/releases/latest/download/bootstrap-salt.sh | bash -s -- -X -d -x python3 || exit 1
}

install_vim_syntax_highlighting() {
    if [ -n "${SUDO_UID}" ] ; then
        home=$(getent passwd "${SUDO_UID}" | cut -d: -f6)
    else
        home=~
    fi
    for i in ftdetect ftplugin indent ; do
        if [ -f "${home}"/.vim/${i}/sls.vim ] ; then
            return
        fi
    done
    tmp_dir=$(mktemp -d)
    mkdir -p "${home}"/.vim
    git clone https://github.com/saltstack/salt-vim "${tmp_dir}"
    cp -r "${tmp_dir}"/ftdetect "${tmp_dir}"/ftplugin "${tmp_dir}"/syntax "${home}"/.vim/
    if [ -n "${SUDO_UID}" ] ; then
        # shellcheck disable=SC2153
        chown -R "${SUDO_UID}":"${SUDO_GID}" "${home}"/.vim
    fi
    rm -fr "${tmp_dir}"
}

get_config_from_github() {
    tmp_dir=$(mktemp -d)
    git clone --branch "${branch}" https://github.com/furlongm/standalone-configuration-management "${tmp_dir}"
    cp -Lr "${tmp_dir}"/saltstack/salt /srv
    cp -r "${tmp_dir}"/saltstack/pillar /srv
    rm -fr "${tmp_dir}"
    run_path=/srv
}

get_local_config() {
    run_path=.
}

main() {
    get_pm
    which git 1>/dev/null 2>&1 || install_deps
    which curl 1>/dev/null 2>&1 || install_deps
    which patch 1>/dev/null 2>&1 || install_deps
    which salt-call 1>/dev/null 2>&1 || install_salt
    install_vim_syntax_highlighting
    if [ -z "${run_locally}" ] ; then
        get_config_from_github
    else
        get_local_config
    fi
    set -e
    salt-call --local --file-root ${run_path}/salt --pillar-root ${run_path}/pillar state.highstate pillar="{'containerized': ${containerized}, 'mail_relay': \"${mail_relay}\", 'root_alias': \"${root_alias}\"}"
}

# defaults
containerized=false
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
            containerized=true
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

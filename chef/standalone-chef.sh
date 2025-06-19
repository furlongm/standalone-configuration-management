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
        ${pm} install --allowerasing which findutils hostname libxcrypt-compat coreutils curl procps gawk dnf-utils
    elif [[ "${ID_LIKE}" =~ "suse" ]] ; then
        pm='zypper -n'
        ${pm} refresh
        ${pm} install gzip hostname
    else
        echo "Error: no package manager found."
        exit 1
    fi
}

install_deps() {
    ${pm} install git curl
}

install_chef() {
    curl -L https://omnitruck.cinc.sh/install.sh | bash || exit 1
}

install_vim_syntax_highlighting() {
    if [ -n "${SUDO_UID}" ] ; then
        home=$(getent passwd "${SUDO_UID}" | cut -d: -f6)
    else
        home=~
    fi
    if [ -f "${home}"/.vim/syntax/chef.vim ] ; then
        return
    fi
    tmp_dir=$(mktemp -d)
    mkdir -p "${home}"/.vim
    git clone https://github.com/vadv/vim-chef "${tmp_dir}"
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
    cp -Lr "${tmp_dir}"/chef /srv
    rm -fr "${tmp_dir}"
    run_path=/srv/chef
}

get_local_config() {
    tmp_dir=$(mktemp -d)
    cp -Lr . "${tmp_dir}"
    run_path=${tmp_dir}
}

main() {
    get_pm
    which git 1>/dev/null 2>&1 || install_deps
    which curl 1>/dev/null 2>&1 || install_deps
    which chef-client 1>/dev/null 2>&1 || install_chef
    install_vim_syntax_highlighting
    if [ -z "${run_locally}" ] ; then
        get_config_from_github
    else
        get_local_config
    fi
    sed -i -e "s#run_path =.*#run_path = '${run_path}'#" "${run_path}"/client.rb
    sed -i -e "s/root_alias.*\"/root_alias\": \"${root_alias}\"/" "${run_path}"/node.json
    sed -i -e "s/mail_relay.*\"/mail_relay\": \"${mail_relay}\"/" "${run_path}"/node.json
    sed -i -e "s/containerized.*/containerized\": ${containerized},/" "${run_path}"/node.json
    set -e
    chef-client -z -j "${run_path}"/node.json -c "${run_path}"/client.rb --chef-license accept
    rm -fr "${tmp_dir}"
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

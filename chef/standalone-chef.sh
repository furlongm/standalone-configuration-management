#!/bin/bash

usage() {
    echo "Usage: $0 -e EMAIL_ADDRESS [-m MAIL_RELAY_HOST] [-l] (as root)"
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
    git clone https://github.com/vadv/vim-chef ${tmp_dir}
    cp -r ${tmp_dir}/* ${home}/.vim/
    if [ ! -z "${SUDO_UID}" ] ; then
        chown -R ${SUDO_UID}:${SUDO_GID} ${home}/.vim
    fi
    rm -fr ${tmp_dir}
}

get_config() {
    tmp_dir=$(mktemp -d)
    if [ -z ${run_locally} ] ; then
        git clone https://github.com/furlongm/standalone-configuration-management ${tmp_dir}
        cp -Lr ${tmp_dir}/chef /srv
        run_path=/srv/chef
    else
        # FIXME don't use relative path
        cp -Lr . ${tmp_dir}
        run_path=${tmp_dir}
    fi
}

main() {
    get_pm
    which git 1>/dev/null 2>&1 || install_deps
    which curl 1>/dev/null 2>&1 || install_deps
    which chef-client 1>/dev/null 2>&1 || install_chef
    install_vim_syntax_highlighting
    get_config
    sed -i -e "s#run_path =.*#run_path = '${run_path}'#" ${run_path}/client.rb
    sed -i -e "s/root_alias.*\"/root_alias\": \"${root_alias}\"/" ${run_path}/node.json
    sed -i -e "s/mail_relay.*\"/mail_relay\": \"${mail_relay}\"/" ${run_path}/node.json
    set -e
    chef-client -z -j ${run_path}/node.json -c ${run_path}/client.rb --chef-license accept
    rm -fr ${tmp_dir}
}

containerized=false
while getopts ":le:m:" opt ; do
    case ${opt} in
        e)
            root_alias=${OPTARG}
            ;;
        l)
            run_locally=.
            ;;
        m)
            mail_relay=${OPTARG}
            ;;
        c)
            containerized=true
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

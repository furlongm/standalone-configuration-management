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
        ${pm} install wget virt-what
    elif [[ "${ID_LIKE}" =~ "rhel" ]] || [[ "${ID_LIKE}" =~ "fedora" ]] || [[ "${ID}" == "fedora" ]] ; then
        pm='dnf -y'
        ${pm} makecache
        ${pm} install --allowerasing which findutils hostname libxcrypt-compat coreutils curl procps gawk virt-what
    elif [[ "${ID_LIKE}" =~ "suse" ]] ; then
        pm='zypper -n --no-gpg-checks --gpg-auto-import-keys'
        ${pm} refresh
        ${pm} install gzip virt-what
    else
        echo "Error: no package manager found."
        exit 1
    fi
}

install_deps() {
    ${pm} install git curl
}

install_puppet() {
    puppet_package=openvox-agent
    if [[ "${pm}" =~ "apt" ]] ; then
        deb=openvox8-release-${ID}${VERSION_ID}.deb
        wget https://apt.voxpupuli.org/"${deb}"
        dpkg -i "${deb}"
        rm "${deb}"
        ${pm} update
    elif [[ "${pm}" =~ "dnf" ]] ; then
        if [[ "${ID}" == "fedora" ]] ; then
            ${pm} install https://yum.voxpupuli.org/openvox8-release-fedora-"${VERSION_ID}".noarch.rpm
        else
            ${pm} install https://yum.voxpupuli.org/openvox8-release-el-"${VERSION_ID/.*/}".noarch.rpm
        fi
        ${pm} makecache
    elif [[ "${pm}" =~ "zypper" ]] ; then
        ${pm} install https://yum.voxpupuli.org/openvox8-release-sles-"${VERSION_ID/.*/}".noarch.rpm
        ${pm} refresh
    fi
    ${pm} install ${puppet_package}
}

install_vim_syntax_highlighting() {
    if [ -n "${SUDO_UID}" ] ; then
        home=$(getent passwd "${SUDO_UID}" | cut -d: -f6)
    else
        home=~
    fi
    for i in ftdetect ftplugin indent syntax ; do
        if [ -f "${home}"/.vim/${i}/puppet.vim ] ; then
            return
        fi
    done
    tmp_dir=$(mktemp -d)
    mkdir -p "${home}"/.vim
    git clone https://github.com/rodjek/vim-puppet "${tmp_dir}"
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
    mkdir -p /etc/puppet/{manifests,modules}
    cp -Lr "${tmp_dir}"/puppet/modules/* /etc/puppet/modules
    cp -r "${tmp_dir}"/puppet/manifests/* /etc/puppet/manifests
    run_path=/etc/puppet
}

get_local_config() {
    tmp_dir=$(mktemp -d)
    cp -Lr ./modules "${tmp_dir}"
    cp -Lr ./manifests "${tmp_dir}"
    run_path=${tmp_dir}
}

main() {
    get_pm
    which git 1>/dev/null 2>&1 || install_deps
    which curl 1>/dev/null 2>&1 || install_deps
    which puppet 1>/dev/null 2>&1 || install_puppet
    install_vim_syntax_highlighting
    if [ -z "${run_locally}" ] ; then
        get_config_from_github
    else
        get_local_config
    fi
    export PATH=/opt/puppetlabs/bin:${PATH}
    export FACTER_root_alias=${root_alias}
    export FACTER_mail_relay=${mail_relay}
    export FACTER_containerized=${containerized}
    puppet module install --target-dir "${run_path}"/modules puppetlabs-mailalias_core
    puppet apply --show_diff --detailed-exitcodes --modulepath "${run_path}"/modules "${run_path}"/manifests/standalone-site.pp
    retval=${?}
    case ${retval} in
        0)
            failed=false
            ;;
        2)
            failed=false
            ;;
        *)
            failed=true
            ;;
    esac
    if [ "${failed}" == "true" ] ; then
        exit 1
    fi
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

#!/bin/bash

usage() {
    echo "Usage: $0 -e EMAIL_ADDRESS (as root)"
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
        ${pm} install which
    elif [[ "${ID_LIKE}" =~ "suse" ]] ; then
        pm='zypper -n'
        ${pm} refresh
    else
        echo "Error: no package manager found."
        exit 1
    fi
}

install_deps() {
    ${pm} install git curl
}

install_puppet() {
    if [[ "${pm}" =~ "dnf" ]] ; then
        ${pm} install https://yum.puppetlabs.com/puppet-release-el-8.noarch.rpm
        ${pm} makecache
    elif [[ "${pm}" =~ "zypper" ]] ; then
        curl -k -O https://yum.puppetlabs.com/RPM-GPG-KEY-puppet
        rpm --import RPM-GPG-KEY-puppet
        rm RPM-GPG-KEY-puppet
        ${pm} ar https://yum.puppetlabs.com/puppet/sles/15/x86_64/ puppet
        ${pm} --gpg-auto-import-keys refresh
    fi
    ${pm} install puppet
}

install_vim_syntax_highlighting() {
    if [ ! -z "${SUDO_UID}" ] ; then
        home=$(getent passwd ${SUDO_UID} | cut -d \: -f 6)
    else
        home=~
    fi
    for i in ftdetect ftplugin indent syntax ; do
        if [ -f ${home}/.vim/${i}/puppet.vim ] ; then
            return
        fi
    done
    tmp_dir=$(mktemp -d)
    mkdir -p ${home}/.vim
    git clone https://github.com/rodjek/vim-puppet ${tmp_dir}
    cp -r ${tmp_dir}/* ${home}/.vim/
    if [ ! -z "${SUDO_UID}" ] ; then
        chown -R ${SUDO_UID}:${SUDO_GID} ${home}/.vim
    fi
    rm -fr ${tmp_dir}
}

get_config_from_github() {
    tmp_dir=$(mktemp -d)
    git clone https://github.com/furlongm/standalone-configuration-management ${tmp_dir}
    mkdir -p /etc/puppet/{manifests,modules}
    cp -Lr ${tmp_dir}/puppet/modules/* /etc/puppet/modules
    cp -r ${tmp_dir}/puppet/manifests/* /etc/puppet/manifests
    rm -fr ${tmp_dir}
}

main() {
    get_pm
    which git 1>/dev/null 2>&1 || install_deps
    which curl 1>/dev/null 2>&1 || install_deps
    which puppet 1>/dev/null 2>&1 || install_puppet
    install_vim_syntax_highlighting
    if [ "${run_path}" != "." ] ; then
        run_path=/etc/puppet
        get_config_from_github
    fi
    sed -i -e "s/admin@example.com/${email}/" ${run_path}/manifests/standalone-site.pp
    export PATH=${PATH}:/opt/puppetlabs/bin
    puppet module install --target-dir ${run_path}/modules puppetlabs-mailalias_core
    puppet apply --show_diff --modulepath ${run_path}/modules ${run_path}/manifests/standalone-site.pp
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

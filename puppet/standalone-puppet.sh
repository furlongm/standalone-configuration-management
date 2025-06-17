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
        ${pm} install wget
    elif [[ "${ID_LIKE}" =~ "rhel" ]] || [[ "${ID_LIKE}" =~ "fedora" ]] || [[ "${ID}" == "fedora" ]] ; then
        pm='dnf -y'
        ${pm} makecache
        ${pm} install --allowerasing which findutils hostname libxcrypt-compat coreutils curl
    elif [[ "${ID_LIKE}" =~ "suse" ]] ; then
        pm='zypper -n --no-gpg-checks --gpg-auto-import-keys'
        ${pm} refresh
        ${pm} install gzip
    else
        echo "Error: no package manager found."
        exit 1
    fi
}

install_deps() {
    ${pm} install git curl
}

install_puppet() {
    puppet_package=puppet-agent
    if [[ "${pm}" =~ "apt" ]] ; then
        deb=puppet8-release-${VERSION_CODENAME}.deb
        wget https://apt.puppet.com/${deb}
        dpkg -i ${deb}
        rm ${deb}
        ${pm} update
    elif [[ "${pm}" =~ "dnf" ]] ; then
        if [[ "${ID}" == "fedora" ]] ; then
            puppet_package=puppet
        else
            ${pm} install https://yum.puppetlabs.com/puppet-release-el-9.noarch.rpm
        fi
        ${pm} makecache
    elif [[ "${pm}" =~ "zypper" ]] ; then
        curl -k -O https://yum.puppetlabs.com/RPM-GPG-KEY-puppet
        rpm --import RPM-GPG-KEY-puppet
        rm RPM-GPG-KEY-puppet
        ${pm} ar https://yum.puppetlabs.com/puppet/sles/15/x86_64/ puppet
        ${pm} refresh
    fi
    ${pm} install ${puppet_package}
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

get_config() {
    tmp_dir=$(mktemp -d)
    if [ -z ${run_locally} ] ; then
        git clone https://github.com/furlongm/standalone-configuration-management ${tmp_dir}
        mkdir -p /etc/puppet/{manifests,modules}
        cp -Lr ${tmp_dir}/puppet/modules/* /etc/puppet/modules
        cp -r ${tmp_dir}/puppet/manifests/* /etc/puppet/manifests
        run_path=/etc/puppet
    else
        # FIXME don't use relative path
        cp -Lr ./modules ${tmp_dir}
        cp -Lr ./manifests ${tmp_dir}
        run_path=${tmp_dir}
    fi
}

main() {
    get_pm
    which git 1>/dev/null 2>&1 || install_deps
    which curl 1>/dev/null 2>&1 || install_deps
    which puppet 1>/dev/null 2>&1 || install_puppet
    install_vim_syntax_highlighting
    get_config
    export PATH=/opt/puppetlabs/bin:${PATH}
    export FACTER_root_alias=${root_alias}
    export FACTER_mail_relay=${mail_relay}
    puppet module install --target-dir ${run_path}/modules puppetlabs-mailalias_core
    puppet apply --show_diff --detailed-exitcodes --modulepath ${run_path}/modules ${run_path}/manifests/standalone-site.pp
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
    rm -fr ${tmp_dir}
}

while getopts ":le:m:" opt ; do
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
        *)
            usage
            ;;
    esac
done

if [[ -z ${root_alias} || ${EUID} -ne 0 ]] ; then
    usage
fi
main

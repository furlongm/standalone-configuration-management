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

install_puppet() {
    if [ -f '/etc/debian_version' ] ; then
        wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
        dpkg -i puppetlabs-release-trusty.deb
        apt-get -y update
        apt-get -y install puppet
        rm -f puppetlabs-release-trusty.deb
    elif [ -f '/etc/redhat-release' ] ; then
        rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
        yum -y install puppet
    elif [ -f '/etc/SuSE-release' ] ; then
        zypper -n install puppet
    fi
}

install_vim_syntax_highlighting() {
    tmp_dir=$(mktemp -d)
    mkdir -p ~/.vim
    git clone https://github.com/puppetlabs/puppet-syntax-vim.git ${tmp_dir}
    cp -r ${tmp_dir}/* ~/.vim/
    rm -fr ${tmp_dir}
}

get_config_from_github() {
    tmp_dir=$(mktemp -d)
    git clone https://github.com/furlongm/standalone-configuration-management ${tmp_dir}
    cp -r ${tmp_dir}/puppet /srv
    rm -fr ${tmp_dir}
}

main() {
    which puppet 1>/dev/null 2>&1 || install_puppet
    install_vim_syntax_highlighting
    get_config_from_github
    if [ "${runlocal}" == "true" ] ; then
        run_path=.
    else
        run_path=/srv/puppet
    fi
    sed -i -e "s/admin@example.com/${email}/" ${run_path}/manifests/site.pp
    puppet apply --show_diff --modulepath ${run_path}/modules ${run_path}/manifests/site.pp
}

while getopts ":le:" opt ; do
    case ${opt} in
        e)
            email=${OPTARG}
            ;;
        l)
            runlocal=true
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

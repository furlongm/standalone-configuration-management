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
        ${pm} install --skip-broken which findutils hostname libxcrypt-compat
    elif [[ "${ID_LIKE}" =~ "suse" ]] ; then
        pm='zypper -n'
        ${pm} refresh
        ${pm} install gzip
    else
        echo "Error: no package manager found."
        exit 1
    fi
}

install_deps() {
    ${pm} install git curl patch
}

install_salt() {
    #curl -L http://bootstrap.saltproject.io | bash -s -- -X -d -x python3 || exit 1
    . /etc/os-release
    if [[ "${ID}" == "debian" ]] ; then
        curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/debian/11/amd64/latest/salt-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/py3/debian/11/amd64/latest bullseye main" | tee /etc/apt/sources.list.d/salt.list
        pm='apt -y'
        ${pm} update
    elif [[ "${ID}" == "ubuntu" ]] ; then
        curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest/salt-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest focal main" | tee /etc/apt/sources.list.d/salt.list
        pm='apt -y'
        ${pm} update
    elif [[ "${ID_LIKE}" =~ "rhel" ]] ; then
        rpm --import https://repo.saltproject.io/py3/redhat/8/x86_64/latest/SALTSTACK-GPG-KEY.pub
        curl -fsSL https://repo.saltproject.io/py3/redhat/8/x86_64/latest.repo | tee /etc/yum.repos.d/salt.repo
        pm='dnf -y'
        ${pm} makecache
    elif [[ "${ID_LIKE}" =~ "fedora" ]] || [[ "${ID}" == "fedora" ]] ; then
        pm='dnf -y'
        ${pm} makecache
    elif [[ "${ID_LIKE}" =~ "suse" ]] ; then
        pm='zypper -n'
        ${pm} refresh
    else
        echo "Error: no package manager found."
        exit 1
    fi
    ${pm} install salt-minion
}

install_vim_syntax_highlighting() {
    if [ ! -z "${SUDO_UID}" ] ; then
        home=$(getent passwd ${SUDO_UID} | cut -d \: -f 6)
    else
        home=~
    fi
    for i in ftdetect ftplugin indent ; do
        if [ -f ${home}/.vim/${i}/sls.vim ] ; then
            return
        fi
    done
    tmp_dir=$(mktemp -d)
    mkdir -p ${home}/.vim
    git clone https://github.com/saltstack/salt-vim ${tmp_dir}
    cp -r ${tmp_dir}/ftdetect ${tmp_dir}/ftplugin ${tmp_dir}/syntax ${home}/.vim/
    if [ ! -z "${SUDO_UID}" ] ; then
        chown -R ${SUDO_UID}:${SUDO_GID} ${home}/.vim
    fi
    rm -fr ${tmp_dir}
}

get_config_from_github() {
    tmp_dir=$(mktemp -d)
    git clone https://github.com/furlongm/standalone-configuration-management ${tmp_dir}
    cp -Lr ${tmp_dir}/saltstack/salt /srv
    cp -r ${tmp_dir}/saltstack/pillar /srv
    rm -fr ${tmp_dir}
}

main() {
    get_pm
    which git 1>/dev/null 2>&1 || install_deps
    which curl 1>/dev/null 2>&1 || install_deps
    which patch 1>/dev/null 2>&1 || install_deps
    which salt-call 1>/dev/null 2>&1 || install_salt
    install_vim_syntax_highlighting
    if [ "${run_path}" != "." ] ; then
        run_path=/srv
        get_config_from_github
    fi
    set -e
    if [[ "${ID}" != "fedora" ]] ;  then
        # FIXME: remove patch when saltstack 3005 is released
        curl https://github.com/saltstack/salt/commit/a273fffc857145198f25ba269f7e2493112e55fc.patch > patch
        patch -Np1 -i patch $(find /usr -name "_compat.py" | grep "salt/_") || /bin/true
    fi
    salt-call --local --file-root ${run_path}/salt --pillar-root ${run_path}/pillar state.highstate pillar="{'mail_relay': \"${mail_relay}\", 'root_alias': \"${root_alias}\"}"
}

while getopts ":le:m:" opt ; do
    case ${opt} in
        e)
            root_alias=${OPTARG}
            ;;
        l)
            run_path=.
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

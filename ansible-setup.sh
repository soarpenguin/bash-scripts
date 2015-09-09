#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '
#PATH="$PATH:/usr/bin:/bin:/sbin:/usr/sbin"
#export PATH

MYNAME="${0##*/}"
CURDIR=$(cd "$(dirname "$0")"; pwd);

OS=`uname`
OS=$(echo "$OS" | tr '[A-Z]' '[a-z]')

##################### function #########################
report_err() { echo "${MYNAME}: Error: $*" >&2 ; }

if [ -t 1 ]
then
    RED="$( echo -e "\e[31m" )"
    HL_RED="$( echo -e "\e[31;1m" )"
    HL_BLUE="$( echo -e "\e[34;1m" )"

    NORMAL="$( echo -e "\e[0m" )"
fi

_hl_red()    { echo "$HL_RED""$@""$NORMAL";}
_hl_blue()   { echo "$HL_BLUE""$@""$NORMAL";}

_trace() {
    echo $(_hl_blue '  ->') "$@" >&2
}

_print_fatal() {
    echo $(_hl_red '==>') "$@" >&2
}

_lowercase() {
    echo "$1" | tr '[A-Z]' '[a-z]'
}

_readlink() {
    file=$1

    if [ "x$file" = "x" ]; then
        echo ""
    fi

    if [ "$OS" = "darwin" ]; then
        filename="${file##*/}"
        filedir=$(cd "$(dirname "$file")"; pwd);

        echo "$filedir/$filename"
    else
        echo $(readlink -f $file)
    fi

}

AUTO_INVOKE_SUDO=yes
_invoke_sudo() 
{
    if [ "`id -u`" != "`id -u $1`" ]; then
        _trace "`whoami`:you need to be $1 privilege to run this script.";
        if [ "$AUTO_INVOKE_SUDO" == "yes" ]; then 
            _trace "Invoking sudo ...";
            sudo -u "#`id -u $1`" bash -c "$2";
        fi
        if [ "$OS" != "darwin" ]; then
            exit 0;
        fi
    fi
}


uid=`id -u`

if [ $uid -ne '0' ]; then
    if [ ! -d "${CURDIR}/ansible" ]; then
        _trace "Start git clone ansible code......"
        git clone git://github.com/ansible/ansible.git --recursive
    else
        _trace "Start git pull ansible code......"
        pushd . &>/dev/null
        cd "${CURDIR}/ansible" && git pull --recurse-submodules 
        popd &>/dev/null
    fi
    
    if [ $? -eq 0 ];then
        _trace "Succ: git clone ansible code."
    else
        _print_fatal "Error: git clone failed ......"
    fi    
fi

if [ $uid -ne '0' ]; then 
    _invoke_sudo root "${CURDIR}/$0 $@"
fi

################################## main route #################################
for cmd in apt-get dnf yum port brew pacman; do
    if command -v $cmd >/dev/null; then
        package_manager="$cmd"
        break
    fi
done

if [ x"$package_manager" = "x" ]; then
    _print_fatal "Get package manager failed."
    exit 1
fi

for SOFT in python-simplejson python-paramiko python-yaml python-jinja2 python-httplib2 python-six; do

    if [ "x$SOFT" = "x" ]; then
        _print_fatal "Warn: null string for software."
        continue
    else
        _trace "Notice: start install ${SOFT} ......"
    fi

    CMD="$package_manager install -y $SOFT"
    ret=`$CMD`

    if [ $? -ne 0 ]; then
        _print_fatal "Error: $SOFT is install failed."
        #exit 1
    else
        _trace "Succ: $SOFT is installed."
    fi
done


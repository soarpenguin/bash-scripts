#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '
TMPFILE="pipe.$$"

CURDIR=$(cd "$(dirname "$0")"; pwd);
MYNAME="${0##*/}"

##################### function #########################
_report_err() { echo "${MYNAME}: Error: $*" >&2 ; }

if [ -t 1 ]
then
    RED="$( echo -e "\e[31m" )"
    HL_RED="$( echo -e "\e[31;1m" )"
    HL_GRE="$( echo -e "\e[32;1m" )"
    HL_BLUE="$( echo -e "\e[34;1m" )"

    NORMAL="$( echo -e "\e[0m" )"
fi

_hl_red()    { echo "$HL_RED""$@""$NORMAL";}
_hl_green()  { echo "$HL_GRE""$@""$NORMAL";}
_hl_blue()   { echo "$HL_BLUE""$@""$NORMAL";}

_trace() {
    echo $(_hl_blue '  --->') "$@" >&2
}

_notice() {
    echo $(_hl_green '  ->') "$@" >&2
}

_print_fatal() {
    echo $(_hl_red '  ===>') "$@" >&2
}

################### get docker source code
if [ ! -n ${GOPATH} ]; then
    _print_fatal "please setup gopath first!!!"
    exit 1
fi

basepath="${GOPATH}/src/github.com/docker"
srcpath="${basepath}/docker"

_trace "get latest docker source code to $srcpath."
pushd . &>/dev/null
mkdir -p ${basepath}
if [ ! -d "${srcpath}" ]; then
    cd ${basepath} && git clone --recursive https://github.com/docker/docker.git docker
else
    cd "${srcpath}" && git pull --recurse-submodules
fi

_trace "get go package for docker needed."
cd "${srcpath}" && go get ./...
popd

################### install -y device-mapper
_trace "detect lvm2 and install for docker compile."
pushd . &>/dev/null
# test whether "libdevmapper.h" is installed.
if \
    command -v gcc &> /dev/null \
    && ( echo -e  '#include <libdevmapper.h>\nint main() { return 0; }'| gcc -ldevmapper -xc - -o /dev/null &> /dev/null ) \
; then
    _notice "lvm2 lib and package is already installed."
else
    lvm2path="$CURDIR/lvm2"
    if [ ! -d "$lvm2path" ]; then
        git clone --no-checkout https://git.fedorahosted.org/git/lvm2.git lvm2
        cd ${lvm2path} && git checkout -q v2_02_103
    else
        cd ${lvm2path} && git checkout -q v2_02_103 && git pull
    fi
    cd ${lvm2path} && ./configure --enable-static_link && make device-mapper && sudo make install_device-mapper
fi
popd

################### install sqlite-devel
_trace "install sqlite3 and btrfs"
# List of lib needed.
NEEDED_LIB=(
    libsqlite3-dev
    btrfs-tools
)
pushd . &>/dev/null
# detect sqlite3 installed.
if \
    command -v gcc &> /dev/null \
    && ( echo -e  '#include <sqlite3.h>\nint main() { return 0; }'| gcc -lsqlite3 -xc - -o /dev/null &> /dev/null ) \
; then
    _notice "libsqlite3-dev is already installed."
else
    sudo apt-get install libsqlite3-dev
fi

#### install btrfs
if ! command -v btrfs >/dev/null 2>&1; then
    sudo apt-get install -y btrfs-tools
else
    _notice "btrfs-tools is already installed."
fi

_trace "make build and binary."
cd $srcpath && make build && make binary

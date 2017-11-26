#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '
#PATH="$PATH:/usr/bin:/bin:/sbin:/usr/sbin"
#export PATH

CURDIR=$(cd "$(dirname "$0")"; pwd);
MYNAME="${0##*/}"
DESTDIR="${CURDIR}/cprogram"

DESTDIR="${1-${DESTDIR}}"

RET_OK=0
RET_FAIL=1

##################### function #########################
_report_err() { echo "${MYNAME}: Error: $*" >&2 ; }

if [ -t 1 ]
then
    RED="$( echo -e "\e[31m" )"
    HL_RED="$( echo -e "\e[31;1m" )"
    HL_GREEN="$( echo -e "\e[32;1m" )"
    HL_YELLOW="$( echo -e "\e[33;1m" )"
    HL_BLUE="$( echo -e "\e[34;1m" )"

    NORMAL="$( echo -e "\e[0m" )"
fi

_hl_red()     { echo "$HL_RED""$@""$NORMAL";}
_hl_green()   { echo "$HL_GREEN""$@""$NORMAL";}
_hl_yellow()  { echo "$HL_YELLOW""$@""$NORMAL";}
_hl_blue()    { echo "$HL_BLUE""$@""$NORMAL";}

_notice() {
    echo $(_hl_green '==>') "$@" >&2
}

_trace() {
    echo $(_hl_blue ' ->') "$@" >&2
}

_warn() {
    echo $(_hl_yellow ' ->') "$@" >&2
}

_print_fatal() {
    echo $(_hl_red ' =>') "$@" >&2
}


##################### main route #######################
if [ -d ${DESTDIR} ]; then
    _trace "Start updating code in ${DESTDIR}"
    pushd . &>/dev/null
    cd ${DESTDIR}

    for dir in `find "${DESTDIR}" -maxdepth 3 -name ".git" -type d`; do
        pdir=${dir%/*}
        _notice "Start update code in ${pdir} ..."
        cd "$dir/../" && git pull --recurse-submodules
        if [ $? -eq 0 ]; then
            _trace "Update code in ${pdir} succ."
        else
            _warn "Update code in ${pdir} fail."
        fi
    done

    popd
    _trace "End updating code in ${DESTDIR}"
    exit ${RET_OK}
else
    _print_fatal "No ${DESTDIR} for updating code."
    exit ${RET_FAIL}
fi

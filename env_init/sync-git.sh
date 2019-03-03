#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '
#PATH="$PATH:/usr/bin:/bin:/sbin:/usr/sbin"
#export PATH

CURDIR=$(cd "$(dirname "$0")"; pwd);
MYNAME="${0##*/}"
g_GITLIST=""
g_GITUSER="soarpenguin"

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

_usage() {
    cat << USAGE
Usage: bash ${MYNAME} git.list

Require:
    git.list     git list file for sync operation, eg: dst-git src-git

USAGE

    exit $RET_OK
}

#
# Parses command-line options.
#  usage: _parse_options "$@" || exit $?
#
_parse_options()
{
    declare -a argv

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                _usage
                exit
                ;;
            --)
                shift
                argv=("${argv[@]}" "${@}")
                break
                ;;
            -*)
                _print_fatal "command line: unrecognized option $1" >&2
                return 1
                ;;
            *)
                argv=("${argv[@]}" "${1}")
                shift
                ;;
        esac
    done

    case ${#argv[@]} in
        1)
            command -v greadlink >/dev/null 2>&1 \
                && g_GITLIST=$(greadlink -f "${argv[0]}") || g_GITLIST=$(readlink -f "${argv[0]}")
            #g_GITLIST="${argv[0]}"
            ;;
        0|*)
            _usage 1>&2
            return 1
    ;;
    esac
}


##################### main route #######################
_parse_options "${@}" || _usage

unset dst from
INDEX=0

if [ "x${GOPATH}" == "" ];then
    _print_fatal "Please set GOPATH first"
fi

cd $GOPATH/src
GITDIR="github.com/k8s-ecology"
if [ ! -d $GITDIR ]; then
    mkdir -p "$GITDIR"
fi

if [ -f ${g_GITLIST} ]; then
    while read -r dst from
    do
        dst=${dst#*(:space:)}
        (( INDEX++ ))
        fchar=`echo ${dst} | cut -c -1`

        if [ "x${dst}" == "x" ]; then
            #_print_fatal "Notice: null string for dst git."
            continue
        elif [ "x$fchar" = "x#" ]; then
            sgit=`echo $dst | cut -c 2-`
            _print_fatal "[$INDEX] Warn: skip ${sgit}"
            unset sgit
            continue
        fi
        unset fchar

        cd $GOPATH/src
        _trace "[$INDEX] sync $dst $from"
        dir=`echo $dst | sed 's#^https://##' | sed 's#.git$##'`
        if [ ! -d $dir ]; then
            cd "$GITDIR" && git clone $dst   
            if [ $? -ne 0 ]; then
                _print_fatal "sync $dst failed"
                continue
            fi
        fi

        ## test remote org and add
        cd $GOPATH/src/$dir && git remote -v | grep "^org" || git remote add org $from
        cd $GOPATH/src/$dir && git config user.name "${g_GITUSER}" && git config user.email "${g_GITUSER}@gmail.com"

        ## fetch and sync
        cd $GOPATH/src/$dir && git fetch org \
            && git merge org/master && git push 

        if [ $? -ne 0 ]; then
            _print_fatal "sync $dst failed"
            continue
        fi

    done < ${g_GITLIST}
else
    _print_fatal "No ${g_GITLIST} for sync git."
    exit ${RET_FAIL}
fi

cd $CURDIR
_trace "finished"

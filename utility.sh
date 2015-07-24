#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '
PATH="$PATH:/usr/bin:/bin:/sbin:/usr/sbin"
export PATH

CURDIR=$(cd "$(dirname "$0")"; pwd);
MYNAME="${0##*/}"

RET_OK=0
RET_FAIL=1

##################### function #########################
_report_err() { echo "${MYNAME}: Error: $*" >&2 ; }

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

_is_number() {
    local re='^[0-9]+$'
    local number="$1"

    if [ "x$number" == "x" ]; then
        _print_fatal "error: _is_number need one parameter"
        exit 1
    else
        number=${number//[[:space:]]/}
    fi

    if [[ $number =~ $re ]] ; then
        return 0
    else
        _print_fatal "error: ${number} not a number" >&2
        exit 1
    fi
}

_is_valid_ip() {
    local ip="$1"
    local stat=0

    if [ "x$ip" == "x" ]; then
        return 1
    else
        ip=${ip//[[:space:]]/}
    fi

    ret=`echo "${ip}." | /bin/grep -P "([0-9]{1,3}\.){4}"`

    if [ "$ret" ]; then
        if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            OIFS=$IFS
            IFS='.'
            ip=($ip)
            IFS=$OIFS
            [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
                && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
            stat=$?
        else
            stat=1
        fi
    else
        stat=1
    fi

    return $stat
}

_usage() {
    cat << USAGE
Usage: bash ${MYNAME} [options].

Options:
    -h, --help      Print this help infomation.

USAGE

    exit ${RET_FAIL}
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
            -s|--ssh)
                g_NOPASSWD=1
            	shift
            	;;
            -l|--limit)
                g_LIMIT=${2}
                _is_number "${g_LIMIT}"
            	shift 2
            	;;
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
        2)
            command -v greadlink >/dev/null 2>&1 && g_HOST_LIST=$(greadlink -f "${argv[0]}") || g_HOST_LIST=$(readlink -f "${argv[0]}")
            g_CMD="${argv[1]}"
            ;;
        0|*)
            _usage 1>&2
            return 1
	;;
    esac
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __detect_color_support
#   DESCRIPTION:  Try to detect color support.
#----------------------------------------------------------------------------------------------------------------------
_COLORS=${BS_COLORS:-$(tput colors 2>/dev/null || echo 0)}
__detect_color_support() {
    if [ $? -eq 0 ] && [ "$_COLORS" -gt 2 ]; then
        RC="\033[1;31m"
        GC="\033[1;32m"
        BC="\033[1;34m"
        YC="\033[1;33m"
        EC="\033[0m"
    else
        RC=""
        GC=""
        BC=""
        YC=""
        EC=""
    fi
}
__detect_color_support


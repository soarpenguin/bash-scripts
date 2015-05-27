#!/usr/bin/env bash

# author: soarpenguin@gmail.com
# usage:  init redis configure file.
# Attention: redis template file's port infomation placeholder with "YYYY".

# if you want debug iofo, run like:  set -x in script.
#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '

MYNAME="${0##*/}"
CURDIR=$(cd "$(dirname "$0")"; pwd);

g_DIR="${CURDIR}"
g_TPL_FILE="redis.conf.tpl"
g_REDIS_FILE="redis.conf"
g_PORT_START=6379
g_INST_NUM=1

##################### function #########################
_report_err() { echo "${MYNAME}: Error: $*" >&2 ; }

# if the output is terminal, display infomation in colors.
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

    if ! [[ $number =~ $re ]] ; then
        _print_fatal "error: ${number} not a number" >&2
        exit 1
    else
        return 0
    fi
}

usage() {
    cat << USAGE
Usage: bash ${MYNAME} [options] tplfile.

Options:
    -d, --dir  dir        Src or dst dir for store the final file configure file, default: current_dir.
    -p, --port portnum    Start port for redis, multi instance port range is "port ~ port+num".
    -n, --num  instnum    Instance num to init, port range is: port ~ port+num.
    -h, --help            Print this help infomation.

Require:
    tplfile     Template file name for init script.

Notice:
    Redis template file's port infomation placeholder with "YYYY".
USAGE

    exit 1
}

#
# Parses command-line options.
#  usage: _parse_options "$@" || exit $?
#
function _parse_options()
{
    declare -a argv

    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dir)
                g_DIR="${2}"
            	shift 2
            	;;
            -p|--port)
                g_PORT_START="${2}"
                _is_number "${g_PORT_START}"
                shift 2
            	;;
            -n|--num)
                g_INST_NUM="${2}"
                _is_number "${g_INST_NUM}"
                shift 2
                ;;
            -h|--help)
            	usage
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
            g_TPL_FILE="${argv[0]}"
            ;;
        0|*)
            usage 1>&2
            return 1
	;;
    esac
}

OS=`uname | tr '[A-Z]' '[a-z]'`
if [ "$OS" == "darwin" ]; then
    _readlink="greadlink"
else
    _readlink="readlink"
fi

################################## main route #################################
_parse_options "${@}" || usage

g_PORT_END=$((${g_PORT_START}+${g_INST_NUM}))
g_FINAL_REDISFILE="${g_DIR}/${g_REDIS_FILE}"

g_FINAL_TPLFILE=$(${_readlink} -f "${g_DIR}/${g_TPL_FILE}")
if [ ! -e ${g_FINAL_TPLFILE} ]; then
    _print_fatal "Template configure file $g_FINAL_TPLFILE is not exist."
    usage
fi

#trap "rm -f ${TMPFILE}; exit" INT TERM EXIT
cleanup() {
    rm -f "${TMPFILE}";
}
trap cleanup EXIT TERM EXIT;

for ((port=${g_PORT_START};port<${g_PORT_END};port++))
do
    echo $port
    sed -e s/YYYY/${port}/g "${g_FINAL_TPLFILE}" > "${g_FINAL_REDISFILE}.${port}"
done


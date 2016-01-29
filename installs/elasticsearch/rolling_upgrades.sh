#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '
CURDIR=$(cd "$(dirname "$0")"; pwd);
MYNAME="${0##*/}"
g_NUM=''
g_ACTION=''

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

    if ! [[ $number =~ $re ]] ; then
        _print_fatal "error: ${number} not a number" >&2
        exit 1
    else
        return 0
    fi
}

_usage() {
    cat << USAGE
Usage: bash ${MYNAME} [options].

Options:
    -n num, --number num   Number of total node for cluster. if current node num
                           less then this number, the cluster is unnormal.
			   Required when action is start.

    -h, --help             Print this help infomation.

Require:
    action 'start|stop'

Example:
    bash ${MYNAME} -n 11 start
    bash ${MYNAME} stop
USAGE
    exit 1
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
            -n|--number)
                g_NUM=${2}
                _is_number "${g_NUM}"
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
        1)
            g_ACTION="${argv[0]}"
        ;;
        0|*)
            _usage 1>&2
            return 1
        ;;
    esac
}

stop_rsync() {
    curl -XPUT localhost:9200/_cluster/settings -d '
    {
      "transient": {
        "cluster.routing.allocation.enable": "none"
      }
    }'
    
    curl -s -XGET localhost:9200/_cluster/settings | python -m json.tool

    curl -XPOST localhost:9200/all/_flush/synced
}

start_rsync() { 
    local nodenum=$1

    if [ x"$nodenum" = "x" ];then
        _print_fatal "start_rsync need nodenum for check cluster status."
        exit 1
    fi

    num=`curl -s -XGET localhost:9200/_cat/nodes | wc -l`

    _trace "Cluster node number is $nodenum."   
    while [ $num -lt $nodenum ]; do
        num=`curl -s -XGET localhost:9200/_cat/nodes | wc -l`
        _trace "Waiting all cluster node is ok, current is $num."   
        sleep 1
    done
 
    sleep 150

    curl -XPUT localhost:9200/_cluster/settings -d '
    {
      "transient": {
        "cluster.routing.allocation.enable": "all"
      }
    }'

    curl -s -XGET localhost:9200/_cluster/settings | python -m json.tool

    status=`curl -s -XGET localhost:9200/_cat/health | awk '{print $4}'`
    _trace "Current cluster status is: $status."   
    curl -XGET localhost:9200/_cat/recovery &>/dev/null
}


##################### main route #########################
_parse_options "${@}" || _usage

case "$g_ACTION" in
    start)
        start_rsync "$g_NUM"
        ;;
    stop)
        stop_rsync
        ;;
    *)
        _usage 1>&2
        exit 2
esac

exit $?

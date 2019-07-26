#!/bin/sh

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '
PATH="$PATH:/usr/bin:/bin:/sbin:/usr/sbin"
export PATH

CURDIR=$(cd "$(dirname "$0")"; pwd);
MYNAME="${0##*/}"

RET_OK=0
RET_FAIL=1

g_ClientNode=""
g_ShardList=""
g_Node=""

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

_usage() {
    cat << USAGE
Usage: bash ${MYNAME} clientNode shardList node.

Require:
    clientNode            Client node for cmd can connect cluster by port 9200.
    shardList             Shard list need to fix: first column is index name, second column is shard num.
    node                  Node name for reroute dest node.

Options:
    -h, --help            Print this help infomation.

Example:
     bash ${MYNAME} log5-client-001.ys shardlist log5-datanode-012
USAGE
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
        3)
            g_ClientNode="${argv[0]}"
            g_ShardList="${argv[1]}"
            g_Node="${argv[2]}"
            ;;
        0|*)
            _usage 1>&2
            exit
    ;;
    esac
}

################################## main route #################################
_parse_options "${@}" || _usage

main() {
    _trace "start doing shard reroute....."

    while IFS='' read -r line || [[ -n "$line" ]]; do
       index=`echo $line | awk '{print $1}'`
       shard=`echo $line | awk '{print $2}'`
       echo "$index:$shard"

       curl -s -XPOST -H 'Content-Type: application/json' "http://${g_ClientNode}:9200/_cluster/reroute" -d "{
           \"commands\" : [
               {
                 \"allocate\" : {
                     \"allow_primary\" : true,
                     \"index\" : \"$index\", \"shard\" : $shard, \"node\": \"${g_Node}\"
                 }
               }
           ]
       }" > ${MYNAME}.log 2>&1

       sleep 2s
    done < "${g_ShardList}"
}

main

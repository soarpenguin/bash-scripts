#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '
#export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
curdir=$(cd "$(dirname "$0")"; pwd)
version="1.0.0"
MYNAME="${0##*/}"
_report_err() { echo "${MYNAME}: Error: $*" >&2 ; }

SECTION="all"
INVENTORY="${curdir}/hosts"
FORKS=5

_is_number() {
    local re='^[0-9]+$'
    local number="$1"

    if [ "x$number" == "x" ]; then
        _report_err "_is_number need one parameter"
        exit 1
    else
        number=${number//[[:space:]]/}
    fi

    if [[ $number =~ $re ]] ; then
        return 0
    else
        _report_err "${number} not a number" >&2
        exit 1
    fi
}

_is_null() {
    local str="$1"
    str=${str//[[:space:]]/}

    if [ "x$str" == "x" ]; then
        _report_err "null string."
        exit 1
    fi
}

#
# Prints usage information.
#
function usage()
{
	cat <<USAGE
usage: $MYNAME [OPTIONS] [xxx [VERSION] [-- CONFIGURE_OPTS ...]]
Options:
	-i INVENTORY, --inventory-file=INVENTORY
	                        Specify inventory host file
        -f FORKS, --forks=FORKS
                                Specify number of parallel processes to use(default=5)
	-V, --version		Prints the version
	-h, --help		Prints this message
Examples:
	$MYNAME -V
USAGE
}

#
# Parses command-line options.
#  usage: parse_options "$@" || exit $?
#
function parse_options()
{
    local argv=()
    
    while [[ $# -gt 0 ]]; do
    	case $1 in
    	        -i|--inventory-file)
    		        INVENTORY="$2"
                        _is_null "$INVENTORY"
    			shift 2
    			;;
    	        -S|--section)
    		        SECTION="$2"
                        _is_null "$SECTION"
    			shift 2
    			;;
    	        -f|--forks)
    		        FORKS="$2"
                        _is_number "$FORKS"
    			shift 2
    			;;
    		-V|--version)
    			echo "$MYNAME: $version"
    			exit
    			;;
    		-h|--help)
    			usage
    			exit
    			;;
    		--)
    			shift
    			configure_opts=("$@")
    			break
    			;;
    		-*)
    			_report_err "command line: unrecognized option $1" >&2
    			return 1
    			;;
    		*)
    			argv+=($1)
    			shift
    			;;
    	esac
    done    
}

parse_options "$@" || exit $?

if [ ! -f ${INVENTORY} ]; then
    _report_err "Please check the inventory file."
    exit 1
fi

ansible -i "${INVENTORY}" "${SECTION}" -m raw -a "yum install -y python-simplejson" -u root -f "$FORKS"
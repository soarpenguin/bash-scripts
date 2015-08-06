#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '
curdir=$(cd "$(dirname "$0")"; pwd)
version="1.0.0"
MYNAME="${0##*/}"
_report_err() { echo "${MYNAME}: Error: $*" >&2; }

#The registry server address where you want push the images into
registry=127.0.0.1:5000


echo_g () {
    [ $# -ne 1 ] && return 0
    echo -e "\033[32m$1\033[0m"
}

echo_y () {
    [ $# -ne 1 ] && return 0
    echo -e "\033[33m$1\033[0m"
}

echo_b () {
    [ $# -ne 1 ] && return 0
    echo -e "\033[34m$1\033[0m"
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
usage: $MYNAME [OPTIONS] registry1:tag1 [registry2:tag2...]
Options:
    -r registry, --registry=registry
                    Specify registry web url.
    -V, --version   Prints the version
    -h, --help      Prints this message
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
    	    -r|--registry)
    		    registry="$2"
                _is_null "$INVENTORY"
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
                argv=("${argv[@]}" "${@}")
    			break
    			;;
    		-*)
    			_report_err "command line: unrecognized option $1"
    			return 1
    			;;
    		*)
    			argv+=($1)
    			shift
    			;;
    	esac
    done 

    case ${#argv[@]} in
        0)
            usage 1>&2
            return 1
	;;
    esac
}

if ! command -v docker >/dev/null; then
    _report_err "Please install docker first."
    exit 1
fi

parse_options "$@" || exit $?
[ $# -lt 1 ] && usage && exit

###### main ###### 
for image in "$@"
do
    echo_b "Uploading $image..."

    sudo docker tag $image $registry/$image
    sudo docker push $registry/$image
    sudo docker rmi $registry/$image

    #echo "sudo docker tag $image $registry/$image"
    #echo "sudo docker push $registry/$image"
    #echo "sudo docker rmi $registry/$image"

    echo_g "Done"
done

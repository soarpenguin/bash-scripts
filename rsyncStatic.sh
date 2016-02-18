#/usr/bin/env bash

CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MYNAME="${0##*/}"
LOGFILE="$CURDIR/app.log"
g_THREADS=3

RET_OK=0
RET_FAIL=1

tmpfile="$CURDIR/$$.fifo"
mkfifo $tmpfile
exec 4<>$tmpfile
rm -rf $tmpfile

_usage() {
    cat << USAGE
Usage: bash ${MYNAME} [options] rsynclist.

Options:
    -c, --concurrent num   Thread Nummber for run the command at same time, default: $g_THREADS.

Require:
    rsynclist            Rsync command list for operation.

Notice:
    please check the result output ${LOGFILE}.
USAGE

    exit $RET_OK
}

_report_err() { echo "${MYNAME}: Error: $*" >&2 ; }

_is_number() {
    local re='^[0-9]+$'
    local number="$1"

    if [ "x$number" == "x" ]; then
        _report_err "_is_number need one parameter"
        exit $RET_FAIL
    else
        number=${number//[[:space:]]/}
    fi

    if [[ $number =~ $re ]] ; then
        return 0
    else
        _report_err "${number} not a number" >&2
        exit $RET_FAIL
    fi
}

readlinkf() { perl -MCwd -e 'print Cwd::abs_path shift' $1;}

#
# Parses command-line options.
#  usage: _parse_options "$@" || exit $?
#
_parse_options()
{
    declare -a argv

    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--concurrent)
                g_THREADS="${2}"
                _is_number "${g_THREADS}"
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
            	_report_err "command line: unrecognized option $1" >&2
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
            g_RSYNCLIST=$(readlinkf "${argv[0]}")
            ;;
        0|*)
            _usage 1>&2
            return 1
	;;
    esac
}

function exec_cmd() 
{
    local line="$@"
    if [ x"$line" = "x" ]; then
	    return 1
    fi

    echo timeout -s 9 40 "$line" | "/bin/sh"
    if [ $? -ne 0 ]
    then
        echo ERROR :  $line >> "${LOGFILE}"
        return 1
    fi
}

##################################################
###                  Main
##################################################
echo "======== start  time : `date`" >> "$LOGFILE"
_parse_options "${@}" || _usage

for ((i=1;i<=${g_THREADS};i++))
do
    echo >&4
done

cat "${g_RSYNCLIST}" | grep -v "^ *#" | grep -v "^ *$"  | while read line
do
    read <&4
    {
        exec_cmd "$line"
        echo >&4
    } &
done

sleep 5s
wait
exec 4<&-
echo "======== end  time : `date`" >> "${LOGFILE}"

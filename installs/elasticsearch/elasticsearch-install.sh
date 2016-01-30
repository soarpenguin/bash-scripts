#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '

# Node type of this machine: master/datanode/monitor
# determine which elasticsearch.yml will used, default:master.
g_NODETYPE="master"

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

RET_OK=0
RET_FAIL=1

_hl_red()    { echo "$HL_RED""$@""$NORMAL";}
_hl_blue()   { echo "$HL_BLUE""$@""$NORMAL";}

_trace() {
    echo $(_hl_blue '  ->') "$@" >&2
}

_print_fatal() {
    echo $(_hl_red '==>') "$@" >&2
}

function check_mkdir() {
    local dir=$1

    if [ x"$dir" == "x" ]; then
        _trace "dir string is null."
        return 1
    elif [ -d "${dir}" ]; then
        _trace "dir of ${dir} is existed, skip mkdir."
        return 0
    else
        _trace "mkdir ${dir}"
        mkdir -p ${dir}
        return $?
    fi
}

usage() {
    cat << USAGE
Usage: bash ${MYNAME} [options].

Options:
    -d, --data_dir dir    Data dir for elasticsearch.
    -t, --type nodetype   Node type for elasticsearch.[master(default)/datanode/monitor]
    --soft software       Software file of elasticsearch.
    -h, --help            Print this help infomation.

USAGE

    exit ${RET_FAIL}
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
            -d|--data_dir)
                g_DATA_DIR="${2}"
            	shift 2
            	;;
            --soft)
                g_ELASTICSOFT="${2}"
                shift 2
                ;;
            --force)
                g_FORCE=1
		        shift
		        ;;
            -t|--type)
                g_NODETYPE="${2}"
                shift
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
}


g_FORCE=0
CURDIR=$(cd "$(dirname "$0")"; pwd);
g_ELASTICSOFT=${g_ELASTICSOFT:-"elasticsearch-1.7.2.noarch.rpm"} 
g_ELASTICSOFT="${CURDIR}/${g_ELASTICSOFT}" 

_parse_options "${@}" || usage

if command -v "elasticsearch" >/dev/null; then
    if [ x"$g_FORCE" = "x" ]; then
    	_trace "elasticsearch is intalled."
    	exit ${RET_OK}
    else
    	_trace "reinstall elasticsearch force"
    fi
fi

if [ -f "$g_ELASTICSOFT" ]; then
    rpm -ivh -vv --force --nosignature "$g_ELASTICSOFT" 
    
    if [ $? -eq 0 ]; then
        _trace "Install elasticsearch success."
    else
        _print_fatal "Install elasticsearch failed, please check it yourself!"
        exit ${RET_FAIL}
    fi
fi

g_DATA_DIR="${g_DATA_DIR:-/opt/elasticsearch}"

if [ ! -d "${g_DATA_DIR}" ]; then
    mkdir -p ${g_DATA_DIR}
fi

for dir in data work logs; do
    check_mkdir "${g_DATA_DIR}/${dir}"
done

_trace "chown of dir ${g_DATA_DIR} to elasticsearch:elasticsearch"
chown -R elasticsearch:elasticsearch "${g_DATA_DIR}"

g_CONF_FILE="${CURDIR}/elasticsearch.yml"
if [ "x${g_NODETYPE}" = "x" ]; then
    _print_fatal "Please provide node type for install elasticsearch.(master/datanode/monitor)"
    exit ${RET_FAIL}
elif [ ! -f "${g_CONF_FILE}.${g_NODETYPE}" ]; then
    _print_fatal "Please check node type provide.(master/datanode/monitor)"
    exit ${RET_FAIL}
else
    _trace "mv ${g_CONF_FILE}.${g_NODETYPE} to ${g_CONF_FILE}"
    if [ -f "${g_CONF_FILE}" ]; then
        rm -rf "${g_CONF_FILE}"
    fi
    mv "${g_CONF_FILE}.${g_NODETYPE}" "${g_CONF_FILE}"
fi

hostname=`hostname`; sed -i "s/#node.name: \".*\"/node.name: \"$hostname\"/g" ${g_CONF_FILE}
if [ -f "${g_CONF_FILE}" ]; then
    _trace "cp yaml configure file to /etc/elasticsearch"
    mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.rpm
    cp -rf "${g_CONF_FILE}" /etc/elasticsearch/
else
    _trace "yaml configure file ${g_CONF_FILE} is not existed."
fi

g_SYSCONF_FILE="${CURDIR}/elasticsearch.sysconfig"
if [ -f "${g_SYSCONF_FILE}" ]; then
    _trace "cp yaml configure file to /etc/elasticsearch"
    mv "/etc/sysconfig/elasticsearch" "/etc/sysconfig/elasticsearch.rpm"
    cp -rf "${g_SYSCONF_FILE}" /etc/sysconfig/elasticsearch
else
    _trace "yaml configure file ${g_CONF_FILE} is not existed."
fi

g_EXEC_FILE="${CURDIR}/elasticsearch"
if [ -f "${g_EXEC_FILE}" ]; then
    _trace "cp exec file to /etc/init.d/elasticsearch"
    mv "/etc/init.d/elasticsearch" "/etc/init.d/elasticsearch.rpm"
    cp -rf "${g_EXEC_FILE}" /etc/init.d/elasticsearch
else
    _trace "exec file ${g_EXEC_FILE} is not existed."
fi

g_PLUGIN_FILE="${CURDIR}/marvel-latest.zip"
if [ -f "${g_PLUGIN_FILE}" ]; then
    /usr/share/elasticsearch/bin/plugin -i marvel -u "file://${g_PLUGIN_FILE}"

    if [ $? -eq 0 ]; then
        _trace "Install ${g_PLUGIN_FILE} success."
    else
        _print_fatal "Install ${g_PLUGIN_FILE} failed, please check it yourself!"
    fi
fi

g_PLUGIN_FILE="${CURDIR}/shield-1.2.1.zip"
if [ -f "${g_PLUGIN_FILE}" ]; then
#    /usr/share/elasticsearch/bin/plugin -i shield -u "file://${g_PLUGIN_FILE}"

    if [ $? -eq 0 ]; then
        _trace "Install ${g_PLUGIN_FILE} success."
    else
        _print_fatal "Install ${g_PLUGIN_FILE} failed, please check it yourself!"
    fi
fi

g_PLUGIN_FILE="${CURDIR}/license-latest.zip"
if [ -f "${g_PLUGIN_FILE}" ]; then
#    /usr/share/elasticsearch/bin/plugin -i license -u "file://${g_PLUGIN_FILE}"

    if [ $? -eq 0 ]; then
        _trace "Install ${g_PLUGIN_FILE} success."
    else
        _print_fatal "Install ${g_PLUGIN_FILE} failed, please check it yourself!"
    fi
fi

#if [ $? -eq 0 ]; then
#    /sbin/chkconfig --add elasticsearch
#fi


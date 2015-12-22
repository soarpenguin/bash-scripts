#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '

MYNAME="${0##*/}"
CURDIR=$(cd "$(dirname "$0")"; pwd)

chmod +x ${CURDIR}/bin/start
MYIP=`ifconfig | grep "inet addr:10\." | grep -oP "((\d+\.)){3}(\d+)" | head -n 1`

nohup ${CURDIR}/bin/start \
    --master zk://10.10.11.3:2181,10.10.11.4:2181,10.10.11.5:2181/mesos \
    --zk zk://10.10.11.3:2181,10.10.11.4:2181,10.10.11.5:2181/marathon \
    --hostname "${MYIP}" --http_credentials "1verge:8bio8cwa" \
    </dev/null >/dev/null 2>&1 &


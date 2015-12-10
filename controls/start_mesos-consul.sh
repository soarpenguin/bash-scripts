#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '

MYNAME="${0##*/}"
PROG="mesos-dns"
CURDIR=$(cd "$(dirname "$0")"; pwd)
PIDFILE="/var/run/${PROG}.pid"
LOGFILE="/opt/log/${PROG}.log"
EXEC="$PROG"
ACTION=""

ZK_INFO="zk://10.10.11.3:2181,10.10.11.4:2181,10.10.11.5:2181/mesos"

nohup "$CURDIR/mesos-consul" --zk=${ZK_INFO} --refresh=30s  &


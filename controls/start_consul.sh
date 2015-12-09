#!/usr/bin/env bash

export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '

MYNAME="${0##*/}"
CURDIR=$(cd "$(dirname "$0")"; pwd)
MYIP=`ifconfig | grep "inet addr:10\." | grep -oP "((\d+\.)){3}(\d+)" | head -n 1`
MYID=`ifconfig | grep "inet addr:10\." | grep -oP "((\d+\.)){3}(\d+)" | head -n 1 | awk -F\. '{print $NF}'`

nohup ${CURDIR}/consul agent -server -bootstrap-expect 3 \
              -node="mesos-${MYID}" -data-dir "$CURDIR/data" \
              -atlas-join \
              -client=0.0.0.0 \
              -config-dir "$CURDIR/consul.d" \
              -ui-dir "$CURDIR/ui" \
              -bind="${MYIP}" \
              </dev/null >/dev/null 2>&1 &

#             -bind="${MYIP}" \


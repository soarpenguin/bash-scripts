#!/usr/bin/env bash

nohup ./bin/start \
    --master zk://10.10.11.3:2181,10.10.11.4:2181,10.10.11.5:2181/mesos \
    --zk zk://10.10.11.3:2181,10.10.11.4:2181,10.10.11.5:2181/marathon \
    </dev/null >/dev/null 2>&1 &


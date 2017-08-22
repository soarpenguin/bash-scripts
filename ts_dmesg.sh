#!/bin/sh

uptime_ts=`cat /proc/uptime | awk '{ print $1}'`
#echo $uptime_ts
dmesg | awk -v uptime_ts=$uptime_ts 'BEGIN {
    now_ts = systime();
    start_ts = now_ts - uptime_ts;
    #print "system start time:", strftime("[%Y/%m/%d %H:%M:%S]", start_ts);
 }
 {
    print strftime("[%Y/%m/%d %H:%M:%S]", start_ts + substr($1, 2, length($1) - 2)), $0
}'

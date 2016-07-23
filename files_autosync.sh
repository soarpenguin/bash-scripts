#!/bin/bash
## autorsync files
## 2015-08-25 soarpenguin

user=named
inotifywait=/usr/bin/inotifywait
rsync=/usr/bin/rsync
curdir=$(cd "$(dirname "$0")"; pwd);

succ_log="$curdir/logs/autosync.log"
fail_log="$curdir/logs/autosync.err"
file_path="$curdir/etc"
dst="named_etc"
ip_list="10.10.1.13"

mkdir -p "$curdir/logs"

$inotifywait -mrq --timefmt '%d/%m/%y %H:%M' --format '%T %w%f' -e modify,delete,create,attrib $file_path | while read files
do
    for host in $ip_list
    do
        $(ping -c 1 $host > /dev/null 2>&1)
        status=$?
        if [[ $status == "0" ]]
        then
            $rsync -vzrtopg --delete --progress --password-file=/etc/rsyncd.password $file_path $user@$host::$dst
            echo "$(date) $host sync Success" >> "$succ_log"
            echo $host
        else
            echo "$(date) $host is not Active" >> "$fail_log"
        fi
    done
done

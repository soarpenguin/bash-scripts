# http://blog.csdn.net/wangbin579/article/details/8950282
# https://github.com/session-replay-tools/tcpcopy

##########  source machine ### 10.100.111.11
#!/usr/bin/env bash

./sbin/tcpcopy -x 80-10.100.111.112:80 -s 10.100.111.113 -c 10.100.150.x -d



##########  target machine ### 10.100.111.112
#!/usr/bin/env bash

ip r d 10.100.150.0/24 via 10.100.111.113
route add -net 10.100.150.0 netmask 255.255.255.0 gw 10.100.111.113



##########  assistant machine ### 10.100.111.113
./sbin/intercept -i eth0 -F 'tcp and src port 80' -d


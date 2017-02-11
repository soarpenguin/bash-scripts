#!/usr/bin/env bash

yum -y install libnl
rpm -ivh libconfig-1.3.2-1.1.el6.x86_64.rpm lldpad-libs-0.9.46-3.el6_5.x86_64.rpm lldpad-0.9.46-3.el6_5.x86_64.rpm
cp -rf ./lldpad.conf  /var/lib/lldpad/lldpad.conf
/etc/init.d/lldpad start

rpm -ivh vconfig-1.9-16.el7.x86_64.rpm 
# add tag
echo "/etc/init.d/network restart" >> /etc/rc.local
echo "vconfig add eth0 5" >> /etc/rc.local
echo "ifconfig eth0.5 10.10.5.14 netmask 255.255.255.0 up" >> /etc/rc.local

# remove IPADDR
sed -r 's/(IPADDR=*)/#\1/' /etc/sysconfig/network-scripts/ifcfg-eth0 -i

# get eth0 route info
# modify eth0 interface route "access" -> "trunk"
#lldptool -t -n -i eth0

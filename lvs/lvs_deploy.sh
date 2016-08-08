#!/bin/bash

MACADDR=${1}
IPADDR=`cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep IPADDR  | awk -F"=" '{print $2}'`

if [[ ${MACADDR} == "" ]];then
        exit
fi

# make sure loaded modules
modprobe bonding
modprobe 8021q

# create the bond0 config: /etc/modprobe.d/bonding.conf & /etc/sysconfig/network-scripts/ifcfg-bond0
echo "alias bond0 bonding" > /etc/modprobe.d/bonding.conf
echo "options bond0 miimon=100 mode=4 xmit_hash_policy=layer3+4" >> /etc/modprobe.d/bonding.conf

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
BOOTPROTO=static
ONBOOT=yes
TYPE=Ethernet
MACADDR=${MACADDR}
EOF

# create the eth1 config
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE="eth1"
BOOTPROTO="static"
ONBOOT="yes"
TYPE="Ethernet"
MACADDR=${MACADDR}
EOF

# install rpms for lvs : ipvsadm & keepalived
rpm -Uvh http://10.10.1.1/www/rpm/software/ipvsadm-1.25-10.el6.x86_64.rpm
rpm -Uvh http://10.10.1.1/www/rpm/software/keepalived-1.2.7-3.el6.x86_64.rpm

# download some scripts
#  init NIC queue
if [[ -e /opt/scripts ]];then
        wget http://10.10.1.1/www/init_lvs.sh -O /opt/scripts/init_lvs.sh
else
        mkdir -p /opt/scripts
        wget http://10.10.1.1/www/init_lvs.sh -O /opt/scripts/init_lvs.sh
fi

# add config to /etc/rc.local
echo "" >> /etc/rc.local
echo "# binding eth1" >> /etc/rc.local
echo "ifenslave bond0 eth1" >> /etc/rc.local
echo "# ipvsadm setting" >> /etc/rc.local
echo "ipvsadm --set 30 5 30" >> /etc/rc.local
echo "# init NIC queue" >> /etc/rc.local
echo "sh /opt/scripts/init_lvs.sh  0 eth0" >> /etc/rc.local
echo "sh /opt/scripts/init_lvs.sh  8 eth1" >> /etc/rc.local
echo "" >> /etc/rc.local
echo "# local vconfig" >> /etc/rc.local
echo "# vconfig add eth0 6" >> /etc/rc.local
echo "# ifconfig eth0.6 ${IPADDR} netmask 255.255.255.0 up" >> /etc/rc.local
echo "# ip ro add 10.0.0.0/8 via 10.103.6.254" >> /etc/rc.local

# off irqbalance
chkconfig irqbalance off

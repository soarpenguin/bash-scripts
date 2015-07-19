#!/bin/bash

echo -e "alias bond0 bonding\noptions bond0 miimon=100 mode=4 xmit_hash_policy=layer3+4" >> /etc/modprobe.d/dist.conf
mv  /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0.back
mv  /etc/sysconfig/network-scripts/ifcfg-eth1 /etc/sysconfig/network-scripts/ifcfg-eth1.back
echo -e "DEVICE=bond0\nBOOTPROTO=static\nONBOOT=yes\nTYPE=Ethernet" > /etc/sysconfig/network-scripts/ifcfg-bond0
echo -e "DEVICE=bond0:1\nBOOTPROTO=static\nONBOOT=yes\nTYPE=Ethernet" > /etc/sysconfig/network-scripts/ifcfg-bond0:1

cat /etc/sysconfig/network-scripts/ifcfg-eth1.back | grep -i IPADDR>> /etc/sysconfig/network-scripts/ifcfg-bond0
cat /etc/sysconfig/network-scripts/ifcfg-eth1.back | grep -i NETMASK>> /etc/sysconfig/network-scripts/ifcfg-bond0

cat /etc/sysconfig/network-scripts/ifcfg-eth0.back | grep -i IPADDR>> /etc/sysconfig/network-scripts/ifcfg-bond0:1
cat /etc/sysconfig/network-scripts/ifcfg-eth0.back | grep -i NETMASK>> /etc/sysconfig/network-scripts/ifcfg-bond0:1

echo "ifenslave bond0 eth0 eth1" >> /etc/rc.local
rm -rf /etc/sysconfig/network-scripts/ifcfg-eth0.back
rm -rf /etc/sysconfig/network-scripts/ifcfg-eth1.back

echo -e "DEVICE=eth0\nBOOTPROTO=none\nONBOOT=yes" > /etc/sysconfig/network-scripts/ifcfg-eth0
echo -e "DEVICE=eth1\nBOOTPROTO=none\nONBOOT=yes" > /etc/sysconfig/network-scripts/ifcfg-eth1
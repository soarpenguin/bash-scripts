#!/bin/bash

mkdir -p /mnt/rhel7-repo
mount -o loop RHEL-LE-7.1-20150219.1-Server-ppc64le-dvd1.iso /mnt/rhel7-repo/

apt-get install yum
mkdir /rhel7-root
export rpm_root=/rhel7-root

rpm --root ${rpm_root} --initdb
rpm --root ${rpm_root} -ivh /mnt/rhel7-repo/Packages/redhat-release-server-7.1-1.ael7b.ppc64le.rpm

rm -f ${rpm_root}/etc/yum.repos.d/*.repo
cat >${rpm_root}/etc/yum.repos.d/rhel71le.repo<
[rhel71le]
baseurl=file:///mnt/rhel7-repo
enabled=1
EOF

rpm --root ${rpm_root} --import  /mnt/rhel7-repo/RPM-GPG-KEY-redhat-*

yum -y --installroot=${rpm_root} install yum

chroot ${rpm_root} /bin/bash
#bash-4.2# cat /etc/redhat-release 

tar -C ${rpm_root}/ -c . | docker import - rhel7le

docker images

docker run --hostname='rhel7-container' rhel7le uname -a


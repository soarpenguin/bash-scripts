#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '

prefixdir=/opt/zookeeper
zoocfg=/etc/zookeeper/conf/zoo.cfg

######## install zookeeper
yum install -y zookeeper.x86_64 zookeeper-server.x86_64 --nogpgcheck
if [ $? -ne 0 ]; then
    echo "Install zookeeper failed."
    exit 1
fi

######## change zookeeper data dir.
mkdir -p ${prefixdir}/{data,log}
sed -i "s#dataDir=.*#dataDir=${prefixdir}/data#" "${zoocfg}"

sed -i "s#export ZOO_LOG_DIR=.*#export ZOO_LOG_DIR=\${ZOO_LOG_DIR:-${prefixdir}/log}#" /usr/bin/zookeeper-server

######## set zookeeper cluster ip.
sed -i '/2888:3888/d' "${zoocfg}"

cat >> "${zoocfg}" <<EOF
server.3=10.10.11.3:2888:3888
server.4=10.10.11.4:2888:3888
server.5=10.10.11.5:2888:3888
EOF

######## initialize zookeeper myid
myid=`ifconfig | grep "inet addr:10\." | grep -oP "((\d+\.)){3}(\d+)" | head -n 1 | awk -F\. '{print $NF}'`
zookeeper-server-initialize --myid=${myid}
if [ $? -ne 0 ]; then
    echo "Initialize zookeeper myid failed."
    exit 1
fi

for dir in ${prefixdir}/{data,log}; do
    chown zookeeper:zookeeper -R "${dir}"
done

echo "Initialize zookeeper cluster host successed."


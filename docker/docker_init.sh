#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '
TMPFILE="pipe.$$"

CURDIR=$(cd "$(dirname "$0")"; pwd);
MYNAME="${0##*/}"

################### get docker source code
pushd . &>/dev/null
basepath="$GOPATH/src/github.com/docker"
srcpath="$basepath/docker"

mkdir -p ${basepath}
if [ ! -d "$srcpath" ]; then
    cd ${basepath} && git clone --recursive https://github.com/docker/docker.git docker
else    
    cd "${srcpath}" && git pull --recurse-submodules
fi
cd "${srcpath}" && go get ./...
popd 

################### install -y device-mapper
pushd . &>/dev/null
lvm2path="$CURDIR/lvm2"
if [ ! -d "$lvm2path" ]; then
    git clone --no-checkout https://git.fedorahosted.org/git/lvm2.git lvm2 
    cd ${lvm2path} && git checkout -q v2_02_103
else    
    cd ${lvm2path} && git checkout -q v2_02_103 && git pull
fi
cd ${lvm2path} && ./configure --enable-static_link && make device-mapper && sudo make install_device-mapper
popd

################### install sqlite-devel
pushd . &>/dev/null
sudo apt-get install libsqlite3-dev

#### install btrfs
sudo apt-get install -y btrfs-tools

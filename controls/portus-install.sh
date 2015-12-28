#!/usr/bin/env bash

#set -x
export PS4='+ [`basename ${BASH_SOURCE[0]}`:$LINENO ${FUNCNAME[0]} \D{%F %T} $$ ] '

MYNAME="${0##*/}"
CURDIR=$(cd "$(dirname "$0")"; pwd)

############## install mariadb ###################
MariadbPath="${CURDIR}/mariadb"
pushd . &>/dev/null
yum install -y git tar gcc-c++ bison ncurses-devel ncurses-libs cmake zlib-devel rpm-build
if [ ! -d ${MariadbPath} ]; then
    git clone https://github.com/MariaDB/server.git ${MariadbPath}
fi

#### build mariadb
cd ${MariadbPath}
git checkout -b mariadb-10.1.9 mariadb-10.1.9 
mkdir -p build
cd build
cmake -DRPM=el6 ../
make package
popd 

#
if [ -d "${MariadbPath}/build" ]; then
    cd ${MariadbPath}/build
    yum install -y MariaDB-10.1.9-el6-x86_64-*.rpm
    service mysql restart
else
    echo "==> Build mariadb first!!!"
    exit 1
fi
popd

############## install ruby ###################
yum install ruby ruby-devel rubygem-bundler

############## install ruby ###################
#chmod +x ${CURDIR}/ibm-4.2.3.0-node-v4.2.3-linux-x64.bin
#${CURDIR}/ibm-4.2.3.0-node-v4.2.3-linux-x64.bin

cat > /etc/profile.d/node-path.sh<<EOF
export PATH=$PATH:/root/node/bin
EOF
chmod +x /etc/profile.d/node-path.sh
source /etc/profile.d/node-path.sh


############## install Portus ###################
PortusPath="${CURDIR}/Portus"
pushd . &>/dev/null
if [ ! -d ${PortusPath} ]; then
    git clone https://github.com/SUSE/Portus.git ${PortusPath}
    cd ${PortusPath}
    bundle config build.nokogiri --use-system-libraries
    bundle install
fi
cd ${PortusPath}
#yum install -y screen
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed

exit 1
############## install Portus ###################
screen -S puma

puma -b tcp://0.0.0.0:3000 -w 3


screen -S catalog

cd ${PortusPath}
CATALOG_CRON="5.minutes" bundle exec crono 
popd

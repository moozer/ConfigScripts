#!/bin/sh

# must be root
if [ ! $(id -u) = "0" ]; then
	echo "must be root"
	echo "Note: sudo is usually not enough due to some paths"
	exit 1
fi

# check who is logged in
who -q | grep sysuser > /dev/null
if [ $? = "0" ]; then
	echo "Default is to change the sysuser."
	echo "Sysuser is currently logged in. aborting."
	exit 2
fi;

# all of the following as root
# install from scratch
# fra
# http://metaconfig.com/download/


wget -O- http://bootstrap.sikkerhed.org/sikkerhedorg.pub 2> /dev/null | apt-key add -
echo "deb http://debian.sikkerhed.org/ stable main" > /etc/apt/sources.list.d/metaconfig.list
apt-get update

apt-get dist-upgrade -y

# Under /opt/metaconfig lægger vi data
apt-get -y install git
mkdir -p opt
cd /opt
git clone git://gitserver/Metaconfig_mozrepo.git
git clone git://gitserver/Metaconfig-base.git

# metaconfig part
apt-get -y install metaconfig

cd /etc/metaconfig/res
if [ ! -e mozrepo ]; then
	ln --symbolic /opt/Metaconfig_mozrepo/mozrepo/ .
fi
if [ ! -e public ]; then
	ln --symbolic /opt/Metaconfig-base/public/ .
fi
cd /etc/metaconfig/node
if [ ! -e config ]; then
	ln --symbolic ../res/mozrepo/default/config .
fi

# to avoid certain issues...
/etc/init.d/nfs-common stop
apt-get -y install zsh

# and update everything
metaconfig -aa
#dpkg-reconfigure -a -u

echo "if you have errors"
echo " dpkg-reconfigure <pkg> to reconfigure a package"
echo " apt-get install --reinstall <pkg> to reinstall if reconfigure does not work"
echo "we have changed a lot, please reboot"
echo "  reboot"

# den blev åbenbart ikke helt færdig
#metaconfig -aa
#dpkg --reconfigure -a
#apt-get --reinstall install lftp
#metaconfig -aa



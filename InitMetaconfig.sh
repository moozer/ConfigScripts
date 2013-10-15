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

echo "Installing metaconfig repos"
wget -O- http://bootstrap.sikkerhed.org/sikkerhedorg.pub 2> /dev/null | apt-key add -
echo "deb http://debian.sikkerhed.org/ stable main" > /etc/apt/sources.list.d/metaconfig.list
apt-get update > /dev/null

echo "Upgrading entire system"
apt-get dist-upgrade -y > /dev/null

# Under /opt/metaconfig lægger vi data

echo "retrieving git repos"
apt-get -y install git git-svn
mkdir -p opt
cd /opt
if [ ! -e Metaconfig_mozrepo ]; then
	git clone https://github.com/moozer/Metaconfig_mozpublic.git
fi
if [ ! -e Metaconfig_public ]; then
	git svn clone https://svn.sikkerhed.org/svn/config/projects/metaconfig/public Metaconfig_public
fi

# metaconfig part
echo Installing metaconfig
apt-get -y install metaconfig > /dev/null

cd /etc/metaconfig/res
if [ ! -e mozrepo ]; then
	ln --symbolic /opt/Metaconfig_mozpublic/ mozrepo 
fi
if [ ! -e public ]; then
	ln --symbolic /opt/Metaconfig_public/ public
fi
cd /etc/metaconfig/node
if [ ! -e config ]; then
	cp ../res/mozrepo/default/config .
	nano config
else
	echo "Keeping existing config file"
fi

# to avoid certain issues...
/etc/init.d/nfs-common stop
apt-get -y install zsh

# and update everything
rm /etc/apt/sources.list
metaconfig -aa

echo "if you have errors"
echo " run the command again"
echo "if they persist"
echo " dpkg-reconfigure <pkg> to reconfigure a package"
echo " apt-get install --reinstall <pkg> to reinstall if reconfigure does not work"
echo "we have changed a lot, please reboot"
echo "  reboot"





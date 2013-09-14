#!/bin/sh

if [ "$1" = "" ] || [ "$2" = "" ]; then
	echo "Usage: $0 <old servername login> <new servername>"
	exit 1 
fi

# handle vars
SERVERNAME=$2
OLDNAME=$1
DEFAULTCONFIGFILE="/opt/Metaconfig_mozrepo/mozrepo/default/config"
WORKDIR="/home/gitconfig"

echo adding $SERVERNAME to gitconfig repos
echo - login to current server is: $OLDNAME

echo changing to $WORKDIR
cd $WORKDIR

if [ -d $SERVERNAME.git ]; then
	echo server already exists in repo: $SERVERNAME
	exit 1
fi

echo "init repo for $SERVERNAME"
git init --bare $SERVERNAME.git

# adding the default config
mkdir -p tmp
git clone $SERVERNAME.git tmp/
cd tmp

cat $DEFAULTCONFIGFILE | sed "s/hostname = \".*\"/hostname = \"$SERVERNAME\"/" > config

git config user.email "gitconfig@$SERVERNAME"
git config user.name "gitconfig"
git add -A
git commit -m "first commit"
git push origin master

# and cleanup of tmp stuff
echo remoing temporary files
cd $WORKDIR
rm -rf tmp

# -- handle keys and init on server --
SSH_prefix="command=\"/opt/ConfigScripts/ConfigStore.py $SERVERNAME rw\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty "
SSH_auth_file=".ssh/authorized_keys"

echo generating keys to tmp dir
mkdir -p tmp
ssh-keygen -C metaconfig@$SERVERNAME -f ./tmp/${SERVERNAME}_id_rsa -N ""
echo -n $SSH_prefix >> ./$SSH_auth_file
cat ./tmp/${SERVERNAME}_id_rsa.pub >> ./$SSH_auth_file

echo copy scripts and keys to server
cp /opt/ConfigScripts/UpdateConfig.sh tmp
scp -r tmp $OLDNAME:.
ssh $OLDNAME "sh tmp/UpdateConfig.sh"

#!/bin/sh

#
# Script to add a single repo without a corresponding server
# - useful e.g. for non-linux configuration
#

# FIXME: a lot of magic values...

if [ "$1" = "" ]; then
	echo "Usage: $0 <reponame>"
	exit 1
fi

# handle vars
REPONAME=$1
HOSTNAME=$(hostname)
WORKDIR="/home/gitconfig"

echo "creating repo $REPONAME"

echo changing to $WORKDIR
cd $WORKDIR

if [ -d $REPONAME.git ]; then
	echo server already exists in repo: $REPONAME
	exit 1
fi

echo "init repo for $REPONAME"
git init --bare $REPONAME.git

# -- handle keys and permissions --
SSH_prefix="command=\"/opt/ConfigScripts/ConfigStore.py $REPONAME rw\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty "
SSH_auth_file=".ssh/authorized_keys"

read -p "please paste the public key here:" PUBKEY

echo "adding to $SSH_auth_file"
#echo "$SSH_prefix $PUBKEY"
echo "$SSH_prefix $PUBKEY" >> ./$SSH_auth_file

echo "changing directory ownership to gitconfig user"
chown -R gitconfig:gitconfig $REPONAME.git

echo "all done"
echo "repo should be accessible by"
echo " git clone gitconfig@$HOSTNAME:$REPONAME.git"



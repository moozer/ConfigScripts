#!/bin/sh

CONFIGSERVER="configserver"
KEYLOCATION="/etc/metaconfig/keys"

if ! [ -d /etc/metaconfig ]; then
	echo unable to find metaconfig installation.
	echo please install it and rerun the script
	exit 1
fi

SERVERNAME=$(ls $KEYLOCATION/*.pub | sed 's#/.*/\(.*\)_id_rsa.pub#\1#')
echo "updating metaconfig for $SERVERNAME"

echo "copying keys to $KEYLOCATION"
mkdir -p $KEYLOCATION
mv /home/sysuser/tmp/$SERVERNAME* $KEYLOCATION
chmod 700 $KEYLOCATION

# Ændre ssh config
cat >> /root/.ssh/config << EOF
Host $CONFIGSERVER
        Hostname $CONFIGSERVER
        User gitconfig
        IdentityFile $KEYLOCATION/${SERVERNAME}_id_rsa
EOF

cd /etc/metaconfig
git clone gitconfig@$CONFIGSERVER:$SERVERNAME.git
if [ ! $? = "0" ]; then
	echo "something went wrong cloning from $CONFIGSERVER"
	exit 1
fi

rm -rf node
ln --symbolic $SERVERNAME node

metaconfig -aa

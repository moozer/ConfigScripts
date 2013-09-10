#!/bin/sh

CONFIGSERVER="configserver"
KEYLOCATION="/etc/metaconfig/keys"

echo "copying keys to $KEYLOCATION"
mkdir -p $KEYLOCATION
mv /home/sysuser/tmp/* $KEYLOCATION
chmod 700 $KEYLOCATION

SERVERNAME=$(ls $KEYLOCATION/*.pub | sed 's#/.*/\(.*\)_id_rsa.pub#\1#')
echo "updating metaconfig for $SERVERNAME"

# Ændre ssh config
cat >> /root/.ssh/config << EOF
Host $CONFIGSERVER
        Hostname $CONFIGSERVER
        User gitconfig
        IdentityFile $KEYLOCATION/${SERVERNAME}_id_rsa
EOF

cd /etc/metaconfig
git clone gitconfig@$CONFIGSERVER:$SERVERNAME.git
rm -rf node
ln --symbolic $SERVERNAME node

metaconfig -aa

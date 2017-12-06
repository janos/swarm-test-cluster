#!/bin/sh

keyfile=`ls -1 /data/keystore/* | head -n 1`
if [ ! -f "$keyfile" ]; then geth --datadir /data --password /password account new 1>&2; fi

keyfile=`ls -1 /data/keystore/* | head -n 1`
if [ ! -f "$keyfile" ]; then echo "Could not find nor generate a keyfile" >&2; exit 1; fi

ACCOUNT="`echo -n $keyfile | tail -c 40`"
if [ "$ACCOUNT" == "" ]; then echo "Could not figure out account id" >&2; exit 1; fi

echo $ACCOUNT
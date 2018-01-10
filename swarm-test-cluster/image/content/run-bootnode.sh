#!/bin/sh

if [ "$BOOTNODE_KEY" == "" ]; then echo "BOOTNODE_KEY environment variable is required"; exit 1; fi

mkdir -p /data
keyfile="/data/bootnode.key"
echo -n "${BOOTNODE_KEY}" > "$keyfile"

bootnode --nodekey $keyfile $@

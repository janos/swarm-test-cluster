#!/bin/sh

geth --password /password --datadir /data --unlock "$(/account.sh)" $@

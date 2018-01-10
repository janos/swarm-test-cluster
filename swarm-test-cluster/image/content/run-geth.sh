#!/bin/sh

geth --password /password --datadir $DATADIR --unlock "$(/account.sh)" $@

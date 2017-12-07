#!/bin/sh

swarm --password /password --datadir /data --bzzaccount "$(/account.sh)" $@

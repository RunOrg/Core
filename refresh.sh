#!/bin/sh
PATH=/usr/local/bin:/usr/bin:/bin
git remote update > /dev/null
git status -uno | grep 'branch is behind' -q && git pull && git submodule update && ohm init .
curl http://runorg.com -s > /dev/null

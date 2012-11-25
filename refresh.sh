#!/bin/sh
PATH=/usr/local/bin:/usr/bin:/bin
portals/FFBAD/refresh.sh
portals/FSCF/refresh.sh
portals/MyInnovation/refresh.sh
portals/AssoHelp/refresh.sh
git remote update > /dev/null
git status -uno | grep 'branch is behind' -q && git pull && ohm init .
curl http://runorg.local -s > /dev/null
curl http://dev.runorg.com -s > /dev/null
curl http://runorg.com -s > /dev/null

#!/bin/sh
PATH=/usr/local/bin:/usr/bin:/bin
portals/FFBAD/refresh.sh
portals/FSCF/refresh.sh
portals/MyInnovation/refresh.sh
portals/AssoHelp/refresh.sh
portals/M2014/refresh.sh
portals/Alfortville/refresh.sh
git remote update > /dev/null
git status -uno | grep 'branch is behind' -q && git pull && ohm init .
curl http://runorg.local -s > /dev/null
curl http://runorg.com -s > /dev/null

#!/bin/sh
git remote update
git status -uno | grep 'branch is behind' -q && git pull && ohm init . || echo "Code is up to date!"
curl http://runorg.local > /dev/null
curl http://dev.runorg.com > /dev/null
curl http://runorg.com > /dev/null
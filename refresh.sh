#!/bin/sh
git remote update
git status -uno | grep 'branch is behind' -q && git pull && ohm init . || echo "Code is up to date!"

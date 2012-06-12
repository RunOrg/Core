#!/bin/sh

cd `dirname $0`
ocamlbuild -lib str splash.byte
./splash.byte

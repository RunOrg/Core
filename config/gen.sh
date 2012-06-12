#!/bin/sh

cd `dirname $0`
ocamlbuild -lib str main.byte
./main.byte

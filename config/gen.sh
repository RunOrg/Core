#!/bin/sh

cd `dirname $0`
ocamlbuild -use-ocamlfind -lib str main.byte
./main.byte

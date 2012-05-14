ROOT=$(shell pwd)
OCAMLBUILD=ocamlbuild -Xs ohm -use-ocamlfind -lib ohm -cflags -I,$(ROOT)/ohm/,-I,$(ROOT)/gen/ -lflags -I,$(ROOT)/ohm/,-I,$(ROOT)/gen/ 

all: 
	make -C ohm/src all
	make -C ohm/tool 
	ohm/tool/tool.byte -assets
	$(OCAMLBUILD) main.byte
	cp _build/main.byte ../www/server

distclean: 
	$(OCAMLBUILD) -clean
	rm -rf _build || echo ''
	make -C ohm/src distclean

clean:
	make -C ohm/src clean
	$(OCAMLBUILD) -clean


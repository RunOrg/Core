ROOT=$(shell pwd)
OCAMLBUILD=ocamlbuild -Xs ohm -use-ocamlfind -lib ohm -cflags -g,-I,$(ROOT)/ohm/,-I,$(ROOT)/gen/ -lflags -g,-I,$(ROOT)/ohm/,-I,$(ROOT)/gen/ 

all: 
	(cd .. ; ocaml/ohm/tool/tool.byte assets) 
	$(OCAMLBUILD) main.byte
	cp _build/main.byte ../www/server

distclean: 
	$(OCAMLBUILD) -clean
	rm -rf _build || echo ''

clean:
	$(OCAMLBUILD) -clean


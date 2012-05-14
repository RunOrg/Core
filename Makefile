EXE=www/server
REAL=www/server.real

server:
	make -C ocaml
	cp $(EXE) $(REAL)

gen/gen.native: gen/gen.ml
	(cd gen ; ocamlbuild gen.native -cflag -g -use-ocamlfind) 

generate: gen/gen.native
	gen/gen.native
	cp gen/js/full.js gen/css/full.css www/public/

refresh-views: $(EXE) generate
	$(EXE) --put

reset: $(EXE)
	$(EXE) --reset

clean: 
	make -C ocaml distclean
	rm -f $(EXE) || echo '' 

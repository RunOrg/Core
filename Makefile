EXE=www/server
REAL=www/server.real

full: server put reset

server:
	./plugins.sh
	splash/gen.sh
	config/gen.sh
	make -C ocaml
	cp $(EXE) $(REAL)

put: $(EXE)
	$(EXE) --put

reset: $(EXE)
	$(EXE) --reset

clean: 
	rm -rf _build/*
	make -C ocaml distclean
	rm -f $(EXE) || echo '' 

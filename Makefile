EXE=www/server
REAL=www/server.real

full: server reset

server:
	make -C ocaml
	cp $(EXE) $(REAL)

reset: $(EXE)
	$(EXE) --reset

clean: 
	make -C ocaml distclean
	rm -f $(EXE) || echo '' 

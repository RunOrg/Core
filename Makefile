EXE=www/server
REAL=www/server.real

full: server put reset

server:
	make -C portals
	./plugins.sh
	splash/gen.sh
	config/gen.sh
	ohm plugins.ohmStatic portals/FFBAD FFBAD
	ohm plugins.ohmStatic portals/FSCF FSCF
	ohm plugins.ohmStatic portals/MyInnovation MyInnovation
	ohm plugins.ohmStatic portals/AssoHelp AssoHelp
	ohm plugins.ohmStatic portals/M2014 M2014
	make -C ocaml
	ohm publish
	cp $(EXE) $(REAL)

put: $(EXE)
	$(EXE) --put

reset: $(EXE)
	$(EXE) --reset

clean: 
	rm -rf _build/*
	make -C ocaml distclean
	rm -f $(EXE) || echo '' 

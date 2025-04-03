# Makefile to compile the Gegl-Interface
# Copyright (C) 2025 Florent Monnier
# Permission to use, copy, modify, and/or distribute this software.

GEGL_CFLAGS = $(shell pkg-config --cflags gegl-0.4)
GEGL_CLIBS = $(shell pkg-config --libs gegl-0.4)

OCAMLC_WHERE = $(shell ocamlc -where)
OCAML_GEGL_DIR = gegl

OCAMLMKLIB = ocamlmklib
OCAMLOPT = ocamlopt
OCAMLC = ocamlc

OCAMLFIND = ocamlfind
INSTALL = install
MKDIR = mkdir
SUDO = sudo
CP = cp

lib: gegl.cma
opt: gegl.cmxa

gegl_stubs.o: gegl_stubs.c
	$(OCAMLOPT) -c -ccopt "$(GEGL_CFLAGS)" $<

gegl.cmi: gegl.mli
	$(OCAMLC) -c $<

gegl.cmo: gegl.ml gegl.cmi
	$(OCAMLC) -c $<

gegl.cmx: gegl.ml gegl.cmi
	$(OCAMLOPT) -c $<

gegl.cma: gegl.cmo dllgegl_stubs.so
	$(OCAMLC) -a -o $@ $< -dllib dllgegl_stubs.so

gegl.cmxa: gegl.cmx dllgegl_stubs.so
	$(OCAMLOPT) -a -o $@ $< -cclib -lgegl_stubs -cclib "$(GEGL_CLIBS)"

dllgegl_stubs.so: gegl_stubs.o
	$(OCAMLMKLIB) -o gegl_stubs -ldopt "$(GEGL_CLIBS)" $^

install:
	$(MKDIR) -p $(OCAML_GEGL_DIR)
	$(CP) \
	  dllgegl_stubs.so  \
	  libgegl_stubs.a   \
	  gegl.mli          \
	  gegl.cmi          \
	  gegl.cmo          \
	  gegl.cmx          \
	  gegl.cma          \
	  gegl.cmxa         \
	  $(OCAML_GEGL_DIR)
	$(SUDO) $(CP) -rf $(OCAML_GEGL_DIR) $(OCAMLC_WHERE)/

find_install:
	$(OCAMLFIND) install gegl META \
	  dllgegl_stubs.so  \
	  libgegl_stubs.a   \
	  gegl.mli          \
	  gegl.cmi          \
	  gegl.cmo          \
	  gegl.cmx          \
	  gegl.cma          \
	  gegl.cmxa         \
	  #End

doc:
	mkdir -p doc
	ocamldoc -d doc -html gegl.mli

clean:
	$(RM) *.[oa] *.cm[ioxa] *.cmx[as] *.so
cleanp:
	$(RM) *.png *.jpg

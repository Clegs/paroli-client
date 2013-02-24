# General Makefile for paroli-client

COFFEE_FILES := $(wildcard *.coffee)
COFFEE_JS := ${COFFEE_FILES:.coffee=.js}

.PHONY: all clean distclean install uninstall

all: $(COFFEE_JS)
	./utils/makeexe.sh start.js

%.js: %.coffee
	coffee -c $<

clean:
	@- rm $(COFFEE_JS)

distclean: clean




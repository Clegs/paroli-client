# General Makefile for paroli-client

COFFEE_FILES := $(wildcard *.coffee)
COFFEE_JS := ${COFFEE_FILES:.coffee=.js}

.PHONY: all clean distclean docs install uninstall

all: $(COFFEE_JS)
	./utils/makeexe.sh start.js

%.js: %.coffee
	coffee -c $<
	@- docco $< > /dev/null

clean:
	@- rm $(COFFEE_JS)

distclean: clean

docs:
	@- docco $(COFFEE_FILES)



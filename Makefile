.PHONY: all clean install uninstall

PROG=lolcat
CC?=gcc
CLIB=-lm
CFLAGS=-O2 -std=c11 -Wall
PREFIX?=/usr/local
BINDIR=$(PREFIX)/bin

all: $(PROG)

lolcat: main.c
	$(CC) main.c -o $(PROG) $(CLIB) $(CFLAGS)

clean:
	rm $(PROG)

install:
	mkdir -p $(BINDIR)
	cp $(PROG) $(BINDIR)

uninstall:
	rm -f $(BINDIR)/$(PROG)


.PHONY: all clean install uninstall

PROG=lolcat
CC?=gcc
CLIB=-lm
CFLAGS?=-O2 -std=c11 -Wall
PREFIX?=/usr/local
BINDIR=$(PREFIX)/bin
MANDIR=$(PREFIX)/share/man/man1/
SRC=main.c colour.c
OBJ=$(SRC:.c=.o)

all: $(PROG)

$(PROG): $(OBJ)
	$(CC) $(OBJ) -o $(PROG) $(CLIB) $(CFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm $(OBJ)
	rm $(PROG)

install:
	mkdir -p $(MANDIR)
	cp lolcat.1 $(MANDIR)
	mkdir -p $(BINDIR)
	cp $(PROG) $(BINDIR)

uninstall:
	rm -f $(MANDIR)/lolcat.1
	rm -f $(BINDIR)/$(PROG)


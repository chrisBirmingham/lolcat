.PHONY: all clean install uninstall

PROG=lolcat
CC?=gcc
CLIB=-lm
CFLAGS=-O2 -std=c11 -Wall
PREFIX?=/usr/local
BINDIR=$(PREFIX)/bin
SRC=main.c color.c
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
	mkdir -p $(BINDIR)
	cp $(PROG) $(BINDIR)

uninstall:
	rm -f $(BINDIR)/$(PROG)

.PHONY: all clean install

PROG=lolcat
CC=gcc
CLIB=-lm
CFLAGS=-std=c11 -Wall

all: $(PROG)

lolcat: main.c
	$(CC) main.c -o $(PROG) $(CLIB) $(CFLAGS)

clean:
	rm $(PROG)

install:
	cp $(PROG) /usr/local/bin


EXE=lolcat

.PHONY: all install clean

all: $(EXE)

$(EXE):
	v . -prod

install: $(EXE)
	cp $(EXE) /usr/local/bin

clean:
	rm $(EXE)


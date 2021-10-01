EXE=lolcat
SOURCES=*.v

.PHONY: all install clean

all: $(EXE)

$(EXE): $(SOURCES)
	v . -prod

install: $(EXE)
	cp $(EXE) /usr/local/bin

clean:
	rm $(EXE)


CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: quicklayers.library

ql_hunks.o: ql_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

quicklayers.library: ql_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/quicklayers_0.55(020+).library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o quicklayers.library

CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: slre.library

slre_hunks.o: slre_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

slre.library: slre_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/slre_37.0.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o slre.library

CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: garshnelib.library

garshne_hunks.o: garshne_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

garshnelib.library: garshne_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/Garshnelib_39.1.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o garshnelib.library

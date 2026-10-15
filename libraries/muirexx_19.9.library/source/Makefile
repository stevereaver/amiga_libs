CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: muirexx.library

muirexx_hunks.o: muirexx_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

muirexx.library: muirexx_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/muirexx_19.9.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o muirexx.library

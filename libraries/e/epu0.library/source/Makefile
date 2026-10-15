CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: epu0.library

epu0_hunks.o: epu0_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

epu0.library: epu0_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/epu0.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o epu0.library

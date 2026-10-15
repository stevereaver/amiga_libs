CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: rtgextra.library

rtgextra_hunks.o: rtgextra_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

rtgextra.library: rtgextra_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/rtgextra_1.0.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o rtgextra.library

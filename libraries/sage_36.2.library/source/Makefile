CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: sage.library

sage_hunks.o: sage_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

sage.library: sage_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/sage_36.2.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o sage.library

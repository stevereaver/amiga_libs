CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: owndevunit.library

odu_hunks.o: odu_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

owndevunit.library: odu_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/owndevunit_3.3.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o owndevunit.library

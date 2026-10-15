CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: muilowlevel.library

muilowlevel_hunks.o: muilowlevel_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

muilowlevel.library: muilowlevel_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/muilowlevel_19.9.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o muilowlevel.library

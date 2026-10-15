CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: catharsis.library

catharsis_hunks.o: catharsis_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

catharsis.library: catharsis_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/catharsis_2.11.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o catharsis.library

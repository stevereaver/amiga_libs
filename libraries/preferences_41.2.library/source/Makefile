CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: preferences.library

preferences_hunks.o: preferences_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

preferences.library: preferences_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/preferences_41.2.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o preferences.library

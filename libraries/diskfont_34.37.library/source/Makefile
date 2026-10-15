CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: diskfont.library

diskfont_hunks.o: diskfont_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

diskfont.library: diskfont_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/diskfont_34.37.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o diskfont.library

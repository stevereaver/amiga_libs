CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: diskfont.library

diskfont.library: diskfont_hunks.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ "../binary/diskfont_31.9(WB1.1).library" && echo BYTE-IDENTICAL

diskfont_hunks.o: diskfont_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o diskfont.library
.PHONY: all clean

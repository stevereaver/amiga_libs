CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: diskfont.library

diskfont.library: diskfont_h0.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ "../binary/diskfont_1.3(WB1.0).library" && echo BYTE-IDENTICAL

diskfont_h0.o: diskfont_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o diskfont.library

.PHONY: all clean

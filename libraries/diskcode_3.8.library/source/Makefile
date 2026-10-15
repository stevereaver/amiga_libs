CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: diskcode.library

diskcode_h0.o: diskcode_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

diskcode.library: diskcode_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/diskcode_3.8.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o diskcode.library

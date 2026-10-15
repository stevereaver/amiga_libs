CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: mpega.library

mpega.library: mpega_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/mpega_2.4(PPC).library" && echo BYTE-IDENTICAL

mpega_h0.o: mpega_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o mpega.library

.PHONY: all clean

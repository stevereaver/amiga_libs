CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: xpkIMPL.library

xpkIMPL.library: xpkIMPL_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/xpkIMPL_1.0.79.library" && echo BYTE-IDENTICAL

xpkIMPL_h0.o: xpkIMPL_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o xpkIMPL.library

.PHONY: all clean

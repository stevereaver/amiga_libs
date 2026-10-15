CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: bfbplayTHXS.library

bfb_h0.o: bfb_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

bfbplayTHXS.library: bfb_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/bfbplayTHXS_1.0.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o bfbplayTHXS.library

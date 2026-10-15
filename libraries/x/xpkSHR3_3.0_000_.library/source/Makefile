CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: xpkSHR3.library

xpkSHR3_h0.o: xpkSHR3_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

xpkSHR3.library: xpkSHR3_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/xpkSHR3_3.0(000).library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o xpkSHR3.library

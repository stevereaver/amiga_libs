CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: xpkSHRI.library

xpkSHRI_h0.o: xpkSHRI_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

xpkSHRI.library: xpkSHRI_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/xpkSHRI_2.6(020).library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o xpkSHRI.library

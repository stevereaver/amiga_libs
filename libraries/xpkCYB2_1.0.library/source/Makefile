CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: cyb2.library

cyb2_h0.o: cyb2_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

cyb2.library: cyb2_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/xpkCYB2_1.0.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o cyb2.library

CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: dg8svx.library

dg8svx_h0.o: dg8svx_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

dg8svx_h1.o: dg8svx_h1.s
	$(CC) $(CFLAGS) -c -o $@ $<

dg8svx.library: dg8svx_h0.o dg8svx_h1.o
	$(CC) $(CFLAGS) -o $@ dg8svx_h0.o dg8svx_h1.o
	python3 fixup.py $@
	cmp $@ "../binary/dg8svx_2.1.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o dg8svx.library

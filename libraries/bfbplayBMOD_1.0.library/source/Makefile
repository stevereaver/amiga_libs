CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: bfbplayBMOD.library

bfb_h0.o: bfb_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

bfbplayBMOD.library: bfb_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/bfbplayBMOD_1.0.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o bfbplayBMOD.library

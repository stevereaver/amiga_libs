CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: protracker.library

pt_h0.o: pt_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

protracker.library: pt_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/protracker_37.1.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o protracker.library

CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: amisslmaster.library

am_h0.o: am_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<
am_h1.o: am_h1.s
	$(CC) $(CFLAGS) -c -o $@ $<

amisslmaster.library: am_h0.o am_h1.o
	$(CC) $(CFLAGS) -o $@ $^
	python3 fixup.py $@
	cmp $@ "../binary/amisslmaster_5.17(020).library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o amisslmaster.library

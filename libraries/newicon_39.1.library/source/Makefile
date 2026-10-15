CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: newicon.library

newicon.library: ni_h0.o ni_h1.o
	$(CC) $(CFLAGS) -o $@ ni_h0.o ni_h1.o
	python3 fixup.py $@
	cmp $@ "../binary/newicon_39.1.library" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o newicon.library

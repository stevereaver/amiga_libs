CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: newicon.library

ni_h0.o: ni_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<
ni_h1.o: ni_h1.s
	$(CC) $(CFLAGS) -c -o $@ $<

newicon.library: ni_h0.o ni_h1.o
	$(CC) $(CFLAGS) -o $@ $^
	python3 fixup.py $@
	cmp $@ "../binary/newicon_38.2.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o newicon.library

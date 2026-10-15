CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: calculus.library

calculus_hunks.o: calculus_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

calculus.library: calculus_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/calculus_37.3.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o calculus.library

CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: containerkit.library

containerkit_hunks.o: containerkit_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

containerkit.library: containerkit_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/containerkit_1.1.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o containerkit.library

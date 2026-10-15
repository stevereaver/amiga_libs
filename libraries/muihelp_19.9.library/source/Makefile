CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: muihelp.library

muihelp_hunks.o: muihelp_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

muihelp.library: muihelp_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/muihelp_19.9.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o muihelp.library

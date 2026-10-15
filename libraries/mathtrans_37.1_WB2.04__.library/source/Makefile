CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: mathtrans.library

mt_hunks.o: mt_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

mathtrans.library: mt_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/mathtrans_37.1(WB2.04+).library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o mathtrans.library

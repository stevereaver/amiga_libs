CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: Bootblock.library

Bootblock.library: Bootblock_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/Bootblock_3.1.library && echo BYTE-IDENTICAL

Bootblock_h0.o: Bootblock_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o Bootblock.library

.PHONY: all clean

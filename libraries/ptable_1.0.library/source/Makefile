CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: ptable.library

ptable.library: ptable_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/ptable_1.0.library && echo BYTE-IDENTICAL

ptable_h0.o: ptable_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o ptable.library

.PHONY: all clean

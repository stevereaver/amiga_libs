CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: debox.library

debox.library: debox_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/debox_1.7.library && echo BYTE-IDENTICAL

debox_h0.o: debox_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o debox.library

.PHONY: all clean

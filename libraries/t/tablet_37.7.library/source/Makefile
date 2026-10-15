CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: tablet.library

tablet.library: tablet_h0.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ ../binary/tablet_37.7.library && echo BYTE-IDENTICAL

tablet_h0.o: tablet_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o tablet.library

.PHONY: all clean

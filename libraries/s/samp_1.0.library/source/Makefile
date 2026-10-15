CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: samp.library

samp.library: samp_h0.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ ../binary/samp_1.0.library && echo BYTE-IDENTICAL

samp_h0.o: samp_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o samp.library
.PHONY: all clean

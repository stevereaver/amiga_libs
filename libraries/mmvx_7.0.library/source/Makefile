CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: mmvx.library

mmvx.library: mmvx_h0.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ ../binary/mmvx_7.0.library && echo BYTE-IDENTICAL

mmvx_h0.o: mmvx_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o mmvx.library
.PHONY: all clean

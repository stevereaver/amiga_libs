CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: mcpsupport2.library

mcpsupport2.library: mcp2_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/mcpsupport2_7.1.library && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o mcpsupport2.library

.PHONY: all clean

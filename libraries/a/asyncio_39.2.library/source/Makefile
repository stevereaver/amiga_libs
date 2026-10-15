CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: asyncio.library

asyncio.library: asyncio_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/asyncio_39.2.library && echo BYTE-IDENTICAL

asyncio_h0.o: asyncio_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o asyncio.library

.PHONY: all clean

CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: sz_aio_ahi.library

sz_aio_ahi.library: sz_aio_ahi_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/sz_aio_ahi_0.2.library && echo BYTE-IDENTICAL

sz_aio_ahi_h0.o: sz_aio_ahi_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o sz_aio_ahi.library

.PHONY: all clean

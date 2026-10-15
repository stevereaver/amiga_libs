CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: dpblit.library

dpblit.library: dpblit_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/dpblit.library && echo BYTE-IDENTICAL

dpblit_h0.o: dpblit_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o dpblit.library

.PHONY: all clean

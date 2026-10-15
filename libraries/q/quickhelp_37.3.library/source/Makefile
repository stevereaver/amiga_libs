CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: quickhelp.library

quickhelp.library: quickhelp_h0.o
	$(CC) $(CFLAGS) -o $@ quickhelp_h0.o
	python3 fixup.py $@
	cmp $@ ../binary/quickhelp_37.3.library && echo BYTE-IDENTICAL

quickhelp_h0.o: quickhelp_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o quickhelp.library

.PHONY: all clean

CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: goldenbyte.library

goldenbyte.library: goldenbyte_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/goldenbyte_1.21.library && echo BYTE-IDENTICAL

goldenbyte_h0.o: goldenbyte_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o goldenbyte.library

.PHONY: all clean

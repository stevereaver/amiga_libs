CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: amigametaformat.library

amigametaformat.library: amigametaformat_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/amigametaformat_6.0.library && echo BYTE-IDENTICAL

amigametaformat_h0.o: amigametaformat_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o amigametaformat.library

.PHONY: all clean

CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: utilities.library

utilities.library: utilities_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/utilities_1.2.library && echo BYTE-IDENTICAL

utilities_h0.o: utilities_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o utilities.library

.PHONY: all clean

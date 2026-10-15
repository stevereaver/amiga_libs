CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: fwpenpal.library

fwpenpal.library: fwpenpal_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/fwpenpal_3.0.library && echo BYTE-IDENTICAL

fwpenpal_h0.o: fwpenpal_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o fwpenpal.library

.PHONY: all clean

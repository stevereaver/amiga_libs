CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: rexxhost.library

rexxhost.library: rhost_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/rexxhost_36.14.library && echo BYTE-IDENTICAL

rhost_h0.o: rhost_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o rexxhost.library

.PHONY: all clean

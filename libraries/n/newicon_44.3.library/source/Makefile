CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: newicon.library

newicon.library: newicon_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/newicon_44.3.library && echo BYTE-IDENTICAL

newicon_h0.o: newicon_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o newicon.library

.PHONY: all clean

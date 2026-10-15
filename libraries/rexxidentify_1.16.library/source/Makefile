CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: rexxidentify.library

rexxidentify.library: rexxidentify_h0.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ ../binary/rexxidentify_1.16.library && echo BYTE-IDENTICAL

rexxidentify_h0.o: rexxidentify_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o rexxidentify.library

.PHONY: all clean

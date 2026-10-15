CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: bfbplaymaster.library

bfbplaymaster.library: bfbplaymaster_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/bfbplaymaster_1.0.library && echo BYTE-IDENTICAL

bfbplaymaster_h0.o: bfbplaymaster_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o bfbplaymaster.library

.PHONY: all clean

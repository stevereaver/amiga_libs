CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: newfmt.library

newfmt.library: newfmt_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/newfmt_4.2.library && echo BYTE-IDENTICAL

newfmt_h0.o: newfmt_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o newfmt.library

.PHONY: all clean

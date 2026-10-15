CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: dsp3210.library

dsp3210.library: dsp3210_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/dsp3210_5.0.library && echo BYTE-IDENTICAL

dsp3210_h0.o: dsp3210_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o dsp3210.library

.PHONY: all clean

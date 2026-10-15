CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: dsp3210.library

dsp3210_h0.o: dsp3210_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

dsp3210.library: dsp3210_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/dsp3210_3.4.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o dsp3210.library

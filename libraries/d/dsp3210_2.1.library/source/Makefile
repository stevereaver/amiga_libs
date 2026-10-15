CC = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS = -m68000 -O2 -ffixed-a5 -nostdlib -nostartfiles -fno-builtin

all: dsp3210.library

dsp3210_lib.o: dsp3210_lib.s
	$(CC) -m68000 -c -o $@ $<

dsp3210.o: dsp3210.c
	$(CC) $(CFLAGS) -c -o $@ $<

dsp3210.library: dsp3210_lib.o dsp3210.o
	$(CC) -nostdlib -nostartfiles -o $@ dsp3210_lib.o dsp3210.o

clean:
	rm -f *.o dsp3210.library

.PHONY: all clean

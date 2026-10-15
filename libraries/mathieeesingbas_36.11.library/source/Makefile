CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: mathieeesingbas.library

mathieeesingbas.library: msb_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/mathieeesingbas_36.11.library && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o mathieeesingbas.library

.PHONY: all clean

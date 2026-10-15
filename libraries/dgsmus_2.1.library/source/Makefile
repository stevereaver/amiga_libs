CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: dgsmus.library

dgsmus_h0.o: dgsmus_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

dgsmus.library: dgsmus_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/dgsmus_2.1.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o dgsmus.library

.PHONY: all clean

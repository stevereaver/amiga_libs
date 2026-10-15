CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: amisslmaster.library

amisslmaster.library: amissl_hunks.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ "../binary/amisslmaster_3.6(000).library" && echo BYTE-IDENTICAL

amissl_hunks.o: amissl_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o amisslmaster.library
.PHONY: all clean

CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: regexp.library

regexp.library: regexp_hunks.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ "../binary/regexp_1.0.library" && echo BYTE-IDENTICAL

regexp_hunks.o: regexp_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o regexp.library
.PHONY: all clean

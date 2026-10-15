CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: applauncher.library

applauncher.library: applauncher_h0.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ "../binary/applauncher_37.2.library" && echo BYTE-IDENTICAL

applauncher_h0.o: applauncher_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o applauncher.library
.PHONY: all clean

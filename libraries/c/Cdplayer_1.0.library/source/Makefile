CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: cdplayer.library

cdplayer.library: cdplayer_hunks.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ "../binary/Cdplayer_1.0.library" && echo BYTE-IDENTICAL

cdplayer_hunks.o: cdplayer_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o cdplayer.library
.PHONY: all clean

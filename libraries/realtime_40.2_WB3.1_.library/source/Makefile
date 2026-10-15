CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: realtime.library

realtime.library: realtime_hunks.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ "../binary/realtime_40.2(WB3.1).library" && echo BYTE-IDENTICAL

realtime_hunks.o: realtime_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o realtime.library
.PHONY: all clean

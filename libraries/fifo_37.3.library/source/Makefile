CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: fifo.library

fifo.library: fifo_hunks.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ "../binary/fifo_37.3.library" && echo BYTE-IDENTICAL

fifo_hunks.o: fifo_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o fifo.library
.PHONY: all clean

CC = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS = -m68000 -O2 -ffixed-a5 -nostdlib -nostartfiles -fno-builtin

all: explode.library

explode_lib.o: explode_lib.s
	$(CC) -m68000 -c -o $@ $<

explode.o: explode.c
	$(CC) $(CFLAGS) -c -o $@ $<

explode.library: explode_lib.o explode.o
	$(CC) -nostdlib -nostartfiles -o $@ explode_lib.o explode.o

clean:
	rm -f *.o explode.library

.PHONY: all clean

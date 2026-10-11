CC = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS = -m68000 -O2 -ffixed-a5 -nostdlib -nostartfiles -fno-builtin

all: rexxapp.library

rexxapp_lib.o: rexxapp_lib.s
	$(CC) -m68000 -c -o $@ $<

rexxapp.o: rexxapp.c
	$(CC) $(CFLAGS) -c -o $@ $<

rexxapp.library: rexxapp_lib.o rexxapp.o
	$(CC) -nostdlib -nostartfiles -o $@ rexxapp_lib.o rexxapp.o

clean:
	rm -f *.o rexxapp.library

.PHONY: all clean

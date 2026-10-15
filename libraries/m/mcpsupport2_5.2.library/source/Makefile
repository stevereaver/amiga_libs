# Makefile for mcpsupport2.library 5.2 C reconstruction
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
TARGET  = mcpsupport2.library

$(TARGET): mcpsupport2_lib.o mcpsupport2.o
	$(CC) $(LDFLAGS) -o $@ mcpsupport2_lib.o mcpsupport2.o

mcpsupport2_lib.o: mcpsupport2_lib.s
	$(CC) -m68000 -c -o $@ $<

mcpsupport2.o: mcpsupport2.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

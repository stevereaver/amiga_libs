# Makefile for warpHW.library 1.0 C reconstruction
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
TARGET  = warpHW.library

$(TARGET): warpHW_lib.o warpHW.o
	$(CC) $(LDFLAGS) -o $@ warpHW_lib.o warpHW.o

warpHW_lib.o: warpHW_lib.s
	$(CC) -m68000 -c -o $@ $<

warpHW.o: warpHW.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

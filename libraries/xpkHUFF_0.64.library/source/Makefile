# Makefile for xpkHUFF.library 0.64 C reconstruction
#
# Absolute-longword functab: entries are .long symbol refs, so
# a single link pass suffices (no offset measurement).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkHUFF.library

all: $(TARGET)

xpkHUFF_lib.o: xpkHUFF_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkHUFF_lib.s

xpkHUFF.o: xpkHUFF.c
	$(CC) $(CFLAGS) -c -o $@ xpkHUFF.c

$(TARGET): xpkHUFF_lib.o xpkHUFF.o
	$(CC) $(LDFLAGS) -o $@ xpkHUFF_lib.o xpkHUFF.o

clean:
	rm -f *.o *.nm *.library

.PHONY: all clean

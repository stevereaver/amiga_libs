# Makefile for xpkHUFF.library 0.62 C reconstruction
#
# Absolute-longword functab (10 entries) -- no offset generation pass.
# Single code hunk; LibInit builds the XpkInfo/XpkMode descriptors
# into the library private data (dataSize 0xa8) at run time.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-strict-aliasing \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkhuff.library

all: $(TARGET)

xpkhuff_lib.o: xpkhuff_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkhuff_lib.s

xpkhuff.o: xpkhuff.c
	$(CC) $(CFLAGS) -c -o $@ xpkhuff.c

$(TARGET): xpkhuff_lib.o xpkhuff.o
	$(CC) $(LDFLAGS) -o $@ xpkhuff_lib.o xpkhuff.o

clean:
	rm -f *.o *.library

.PHONY: all clean

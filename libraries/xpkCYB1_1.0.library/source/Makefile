# Makefile for xpkCYB1.library 1.2 C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# The AUTOINIT function table is the absolute-longword variant and is
# assembled directly in xpkCYB1_lib.s -- no two-pass table needed.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkCYB1.library

all: $(TARGET)

$(TARGET): xpkCYB1_lib.o xpkCYB1.o
	$(CC) $(LDFLAGS) -o $@ xpkCYB1_lib.o xpkCYB1.o

xpkCYB1_lib.o: xpkCYB1_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkCYB1_lib.s

xpkCYB1.o: xpkCYB1.c
	$(CC) $(CFLAGS) -c -o $@ xpkCYB1.c

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

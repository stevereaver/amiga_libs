# Makefile for xpkNONE.library 1.2 C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# The AUTOINIT function table is the absolute-longword variant and is
# assembled directly in xpkNONE_lib.s -- no two-pass table needed.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkNONE.library

all: $(TARGET)

$(TARGET): xpkNONE_lib.o xpkNONE.o
	$(CC) $(LDFLAGS) -o $@ xpkNONE_lib.o xpkNONE.o

xpkNONE_lib.o: xpkNONE_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkNONE_lib.s

xpkNONE.o: xpkNONE.c
	$(CC) $(CFLAGS) -c -o $@ xpkNONE.c

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

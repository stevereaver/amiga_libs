# Makefile for xpkFAST.library 1.10 C reconstruction
#
# The functab uses LONG absolute entries (resolved by hunk relocs),
# so no two-pass link is needed.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkFAST.library

all: $(TARGET)

xpkfast_lib.o: xpkfast_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkfast_lib.s

xpkfast.o: xpkfast.c
	$(CC) $(CFLAGS) -c -o $@ xpkfast.c

$(TARGET): xpkfast_lib.o xpkfast.o
	$(CC) $(LDFLAGS) -o $@ xpkfast_lib.o xpkfast.o

clean:
	rm -f *.o *.library

.PHONY: all clean

# Makefile for xpkNUKE.library 1.7 C reconstruction -- 68000 build
#
# Single pass: the 1.7 functab is ABSOLUTE (longwords, -1 terminator),
# so no two-pass offset measurement is needed -- `.long _sym` entries
# assemble directly and the linker emits the self-relocations.
#
# xpkNUKE_lib.o links first so the resident header lands at code+0.
# The XpkMode/XpkInfo descriptors live in .data -> second hunk
# (HUNK_DATA), matching the original two-hunk layout; PackerInfo
# returns a hunk1 pointer via a cross-hunk RELOC32.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkNUKE.library

all: $(TARGET)

xpkNUKE_lib.o: xpkNUKE_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkNUKE_lib.s

xpkNUKE.o: xpkNUKE.c
	$(CC) $(CFLAGS) -c -o $@ xpkNUKE.c

$(TARGET): xpkNUKE_lib.o xpkNUKE.o
	$(CC) $(LDFLAGS) -o $@ xpkNUKE_lib.o xpkNUKE.o

clean:
	rm -f *.o *.library

.PHONY: all clean

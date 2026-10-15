# Makefile for xpkhfmn.library 1.28 (020+) C reconstruction
#
# LONG-offset functab: direct .long symbol entries in xpkhfmn_lib.s,
# no generation pass needed.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkhfmn.library

all: $(TARGET)

xpkhfmn_lib.o: xpkhfmn_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkhfmn_lib.s

xpkhfmn.o: xpkhfmn.c
	$(CC) $(CFLAGS) -c -o $@ xpkhfmn.c

$(TARGET): xpkhfmn_lib.o xpkhfmn.o
	$(CC) $(LDFLAGS) -o $@ xpkhfmn_lib.o xpkhfmn.o

clean:
	rm -f *.o *.library

.PHONY: all clean

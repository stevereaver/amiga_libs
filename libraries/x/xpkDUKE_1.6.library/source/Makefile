# Makefile for xpkDUKE.library 1.6 reconstruction -- 68000 build
#
# The 1.6 library uses a longword-absolute functab (terminated by
# -1), so no two-pass offset measurement is needed; descriptors live
# in .data (second hunk) as in the original.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkDUKE.library

all: $(TARGET)

xpkDUKE_lib.o: xpkDUKE_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkDUKE_lib.s

xpkDUKE.o: xpkDUKE.c
	$(CC) $(CFLAGS) -c -o $@ xpkDUKE.c

$(TARGET): xpkDUKE_lib.o xpkDUKE.o
	$(CC) $(LDFLAGS) -o $@ xpkDUKE_lib.o xpkDUKE.o

clean:
	rm -f *.o *.library

.PHONY: all clean

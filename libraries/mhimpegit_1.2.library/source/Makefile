# Makefile for mhimpegit.library 1.2 C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# The original requires a 68020+ (BSR.L, memory-indirect addressing,
# DIVU.L); the rebuild keeps -m68020 for the inline division.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles

TARGET  = mhimpegit.library

all: $(TARGET)

$(TARGET): mhimpegit_lib.o mhimpegit.o
	$(CC) $(LDFLAGS) -o $@ mhimpegit_lib.o mhimpegit.o

mhimpegit_lib.o: mhimpegit_lib.s
	$(CC) $(ASFLAGS) -c -o $@ mhimpegit_lib.s

mhimpegit.o: mhimpegit.c
	$(CC) $(CFLAGS) -c -o $@ mhimpegit.c

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

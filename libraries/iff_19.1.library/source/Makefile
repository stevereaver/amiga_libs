# Makefile for iff.library 19.1 C reconstruction
#
# Absolute-longword functab: entries are .long symbol refs, so
# a single link pass suffices (no offset measurement).
# iff_lib.o must link first so the resident/bootstrap lands at hunk+0.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos-ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = iff.library

all: $(TARGET)

iff_lib.o: iff_lib.s
	$(CC) $(ASFLAGS) -c -o $@ iff_lib.s

iff.o: iff.c
	$(CC) $(CFLAGS) -c -o $@ iff.c

$(TARGET): iff_lib.o iff.o
	$(CC) $(LDFLAGS) -o $@ iff_lib.o iff.o

clean:
	rm -f *.o *.nm *.library

.PHONY: all clean

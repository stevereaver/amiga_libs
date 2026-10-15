# Makefile for ksort.library 34.1 C reconstruction
#
# Absolute-longword functab: entries are .long symbol refs, so
# a single link pass suffices (no offset measurement).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = ksort.library

all: $(TARGET)

ksort_lib.o: ksort_lib.s
	$(CC) $(ASFLAGS) -c -o $@ ksort_lib.s

ksort.o: ksort.c
	$(CC) $(CFLAGS) -c -o $@ ksort.c

$(TARGET): ksort_lib.o ksort.o
	$(CC) $(LDFLAGS) -o $@ ksort_lib.o ksort.o

clean:
	rm -f *.o *.nm *.library

.PHONY: all clean

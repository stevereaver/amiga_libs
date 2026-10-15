# Makefile for xpkLIN2.library 1.1 (68000) -- assembly reconstruction
#
# Single code hunk; functab = word-offset table (0xffff marker),
# data pointers are absolute longs (RELOC32-covered).
# Rebuilds the original binary BYTE-IDENTICAL.
# -Wl,-s drops the symbol hunk the linker would otherwise append.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = xpkLIN2.library

all: $(TARGET)

xpkLIN2.o: xpkLIN2.s
	$(CC) $(ASFLAGS) -c -o $@ xpkLIN2.s

$(TARGET): xpkLIN2.o
	$(CC) $(LDFLAGS) -o $@ xpkLIN2.o

verify: $(TARGET)
	cmp $(TARGET) '../binary/xpkLIN2_1.1(000).library' && echo IDENTICAL

clean:
	rm -f *.o *.library

.PHONY: all verify clean

# Makefile for xpkMASH.library 1.98 (68020) -- assembly reconstruction
#
# Single code hunk; functab = absolute longs (RELOC32-covered).
# Rebuilds the original binary BYTE-IDENTICAL.
# -Wl,-s drops the symbol hunk the linker would otherwise append.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = xpkMASH.library

all: $(TARGET)

xpkMASH.o: xpkMASH.s
	$(CC) $(ASFLAGS) -c -o $@ xpkMASH.s

$(TARGET): xpkMASH.o
	$(CC) $(LDFLAGS) -o $@ xpkMASH.o

verify: $(TARGET)
	cmp $(TARGET) '../binary/xpkMASH_1.98(020).library' && echo IDENTICAL

clean:
	rm -f *.o *.library

.PHONY: all verify clean

# Makefile for asyncio.library 37.2 reconstruction.
# Two hunks: h0 CODE (functab before RomTag + all code+strings),
# h1 BSS (20B globals; linked as DATA then fixed up to HUNK_BSS).
# fixup.py restores the original RELOC32 grouping/order and the
# BSS hunk type.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = asyncio.library

all: $(TARGET)

$(TARGET): asyncio_h0.o asyncio_h1.o fixup.py
	printf 'SECTIONS { .h0 : { asyncio_h0.o(.text) } .data : { asyncio_h1.o(.bss) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) asyncio_h0.o asyncio_h1.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

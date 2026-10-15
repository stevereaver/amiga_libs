# Makefile for muispecial.library 19.11 reconstruction.
# CODE hunk (with embedded RomTag/strings/functab) + DATA hunk
# (near-data globals incl. the two 3-byte audio waveforms at +0x18).
# GNU ld emits ascending RELOC32 groups and marks the data hunk CODE;
# fixup.py restores the original descending reloc order and DATA tag.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = muispecial.library
ORIG    = ../binary/muispecial_19.11.library

all: $(TARGET)

$(TARGET): muispecial_h0.o muispecial_h1.o fixup.py
	printf 'SECTIONS { .h0 : { muispecial_h0.o(.text) } .h1 : { muispecial_h1.o(.data) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) muispecial_h0.o muispecial_h1.o
	python3 fixup.py $(TARGET) $(ORIG)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

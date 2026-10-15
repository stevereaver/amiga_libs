# Makefile for config.library 1.0 reconstruction.
# Two hunks: h0 CODE 2404B (all code), h1 DATA 340B (strings, globals,
# RomTag, InitTable, datatab, functab -- RomTag lives in DATA!).
# fixup.py rewrites each hunk's RELOC32 groups in the original order
# (h0->h1 leas scrambled; h1->h0 then h1->h1) and restores the hunk
# table size quirk: table says 0x56 longs, DATA hunk header says 0x55.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = config.library
OBJS    = config_h0.o config_h1.o

all: $(TARGET)

$(TARGET): $(OBJS) fixup.py
	printf 'SECTIONS { .h0 : { config_h0.o(.text) } .h1 : { config_h1.o(.data) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) $(OBJS)
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o hunks.x $(TARGET)

.PHONY: all clean

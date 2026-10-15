# Makefile for queue.library 3.1 (Bernhard Fastenrath) reconstruction.
#
# Single .s file: .text = hunk0 (code), .data = [template | functab |
# strings].  The amiga target ld merges every code section into one
# CODE hunk, so the original 3-hunk layout (CODE/DATA/CODE) cannot be
# emitted directly.  fixup.py re-splits the linked DATA hunk into
# hunk1 (8-long template/InitTable) and hunk2 (0x17-long functab +
# strings) and rewrites all RELOC32 groups in the original
# descending-offset order.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = queue.library

all: $(TARGET)

$(TARGET): queue.o fixup.py
	$(CC) $(LDFLAGS) -o $@ queue.o
	python3 fixup.py $@

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

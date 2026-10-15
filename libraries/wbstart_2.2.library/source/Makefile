# Makefile for wbstart.library 2.2 (18.9.96) "WBStart Handler"
#
# Default target: verbatim asm reconstruction (wbstart_h0.s, raw
# .short words + .long refs at relocated slots), byte-identical to
# the shipped binary after fixup.py rewrites the hunk size table
# (DATA hunk allocates 0xa longs but defines only 1) and splices
# the original's non-sorted HUNK_RELOC32 tail back in.
#
CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

ORIG    = ../binary/wbstart_2.2.library
TARGET  = wbstart.library

all: verify

$(TARGET): wbstart_h0.o fixup.py
	$(CC) $(LDFLAGS) -o $@ wbstart_h0.o
	python3 fixup.py $@ "$(ORIG)"

verify: $(TARGET)
	cmp "$(ORIG)" $(TARGET) && echo "byte-identical"

wbstart_h0.o: wbstart_h0.s
	$(CC) $(ASFLAGS) -c -o $@ wbstart_h0.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all verify clean

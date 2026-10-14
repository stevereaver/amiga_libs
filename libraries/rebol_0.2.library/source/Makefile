# Makefile for rebol.library 0.2 reconstruction.
# Single CODE hunk. fixup.py restores the original (non-sorted) RELOC32 order.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = rebol.library

all: $(TARGET)

$(TARGET): rebol.o fixup.py
	$(CC) $(LDFLAGS) -o $(TARGET) rebol.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

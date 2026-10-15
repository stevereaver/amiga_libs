# Makefile for dospath.library 1.0 reconstruction.
# hunk0 CODE (all code+tables), hunk1 DATA (12B-alloc globals, 4B body).
# fixup.py restores the original RELOC32 order and the hunk1 header
# table long (header says 3 longs allocated, record body is 1 long).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = dospath.library

all: $(TARGET)

$(TARGET): dospath.o fixup.py
	$(CC) $(LDFLAGS) -o $(TARGET) dospath.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

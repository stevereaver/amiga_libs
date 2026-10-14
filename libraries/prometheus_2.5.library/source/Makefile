# Makefile for prometheus.library 2.5 reconstruction.
# hunk0 CODE (stub+RomTag+strings+code), hunk1 DATA (18-entry
# MakeLibrary function table + -1 terminator).
# fixup.py restores the original RELOC32 grouping/order.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = prometheus.library

all: $(TARGET)

$(TARGET): prometheus.o fixup.py
	$(CC) $(LDFLAGS) -o $(TARGET) prometheus.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

# Makefile for easylife.library 1.02 reconstruction.
# Single CODE hunk; AUTOINIT. fixup.py restores the original
# RELOC32 grouping/order.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = easylife.library

all: $(TARGET)

$(TARGET): easylife.o fixup.py
	$(CC) $(LDFLAGS) -o $(TARGET) easylife.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

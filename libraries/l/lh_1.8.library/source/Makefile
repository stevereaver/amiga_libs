# Makefile for lh.library 1.8 reconstruction.
# Single CODE hunk. fixup.py restores the original RELOC32 order
# (the InitTable/functab/datatab reloc block then the code relocs).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = lh.library

all: $(TARGET)

$(TARGET): lh.o fixup.py
	$(CC) $(LDFLAGS) -o $(TARGET) lh.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

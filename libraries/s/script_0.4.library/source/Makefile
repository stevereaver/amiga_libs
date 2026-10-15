# Makefile for script.library 0.4 reconstruction.
# Three hunks: h0 CODE (main), h1 DATA (InitTable block copied to
# lib+48 at init), h2 CODE (absolute functab + name/id strings).
# fixup.py restores the original RELOC32 ordering.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = script.library

all: $(TARGET)

$(TARGET): script_h0.o script_h1.o script_h2.o fixup.py
	printf 'SECTIONS { .h0 : { script_h0.o(.text) } .data : { script_h1.o(.data) } .h2 : { script_h2.o(.text) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) script_h0.o script_h1.o script_h2.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

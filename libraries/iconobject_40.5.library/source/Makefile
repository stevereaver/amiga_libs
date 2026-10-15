# Makefile for iconobject.library 40.5 reconstruction.
# CODE hunk (2300 B) + DATA hunk (368 B: strings/functab/InitTable/
# RomTag/globals).  GNU ld emits sorted RELOC32 groups; fixup.py rewrites
# them with the original producer's exact (unsorted, descending-in-h1)
# order and verifies byte-exactness vs ../binary/iconobject_40.5.library.
CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = iconobject.library
ORIG    = ../binary/iconobject_40.5.library

all: $(TARGET)

$(TARGET): iconobject_h0.o iconobject_h1.o fixup.py
	printf 'SECTIONS { .h0 : { iconobject_h0.o(.text) } .h1 : { iconobject_h1.o(.data) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) iconobject_h0.o iconobject_h1.o
	python3 fixup.py $(TARGET) $(ORIG)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

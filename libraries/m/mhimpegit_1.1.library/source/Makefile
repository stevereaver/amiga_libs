# Makefile for mhimpegit.library 1.1 reconstruction.
# CODE hunk + near-data DATA hunk (16 B alloc / 4 B body).
# GNU ld emits RELOC32; fixup.py rewrites the file with the original
# DREL16 (0x3f7) records and verifies byte-exactness against
# ../binary/mhimpegit_1.1.library.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = mhimpegit.library
ORIG    = ../binary/mhimpegit_1.1.library

all: $(TARGET)

$(TARGET): mhimpegit_h0.o mhimpegit_h1.o fixup.py
	printf 'SECTIONS { .h0 : { mhimpegit_h0.o(.text) } .h1 : { mhimpegit_h1.o(.data) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) mhimpegit_h0.o mhimpegit_h1.o
	python3 fixup.py $(TARGET) $(ORIG)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

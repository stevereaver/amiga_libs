# Makefile for easyrexx.library 1.78 reconstruction.
# CODE hunk + 24-byte near-data DATA hunk.  GNU ld emits RELOC32;
# fixup.py reorders the records to the original producer's order and
# verifies byte-exactness against ../binary/easyrexx_1.78.library.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = easyrexx.library
ORIG    = ../binary/easyrexx_1.78.library

all: $(TARGET)

$(TARGET): easyrexx_h0.o easyrexx_h1.o fixup.py
	printf 'SECTIONS { .h0 : { easyrexx_h0.o(.text) } .h1 : { easyrexx_h1.o(.data) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) easyrexx_h0.o easyrexx_h1.o
	python3 fixup.py $(TARGET) $(ORIG)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET) hunks.x

.PHONY: all clean

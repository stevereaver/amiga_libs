# Makefile for cyberlayers.library 40.8 reconstruction.
# Two CODE hunks. GNU ld emits RELOC32; fixup.py rewrites the file with
# the original RELOC32SHORT records and verifies the byte-exact result
# against ../binary/cyberlayers_40.8.library.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = cyberlayers.library
ORIG    = ../binary/cyberlayers_40.8.library

all: $(TARGET)

$(TARGET): cyberlayers_h0.o cyberlayers_h1.o fixup.py
	printf 'SECTIONS { .h0 : { cyberlayers_h0.o(.text) } .h1 : { cyberlayers_h1.o(.text) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) cyberlayers_h0.o cyberlayers_h1.o
	python3 fixup.py $(TARGET) $(ORIG)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

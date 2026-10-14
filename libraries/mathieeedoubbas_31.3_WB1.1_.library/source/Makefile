# Makefile for mathieeedoubbas.library 31.3 (WB1.1) reconstruction.
# Three code hunks (one .o per hunk) + two empty trailer hunks and
# the original's non-sorted RELOC32 order restored by fixup.py.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = mathieeedoubbas.library

all: $(TARGET)

$(TARGET): h0.o h1.o h2.o fixup.py
	printf 'SECTIONS { .h0 : { h0.o(.text) } .h1 : { h1.o(.text) } .h2 : { h2.o(.text) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) h0.o h1.o h2.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

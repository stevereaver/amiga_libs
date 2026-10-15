# Makefile for write.library 4.2 reconstruction.
# Three hunks: h0 CODE (main), h1 CODE (functab+strings), h2 DATA
# (InitTable + runtime template). fixup.py restores the original
# RELOC32 grouping/order.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = write.library

all: $(TARGET)

$(TARGET): write_h0.o write_h1.o write_h2.o fixup.py
	printf 'SECTIONS { .h0 : { write_h0.o(.text) } .h1 : { write_h1.o(.text) } .data : { write_h2.o(.data) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) write_h0.o write_h1.o write_h2.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

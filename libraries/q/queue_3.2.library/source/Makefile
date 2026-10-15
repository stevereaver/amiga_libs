# Makefile for queue.library 3.2 reconstruction.
# Three hunks: h0 CODE (main), h1 DATA (InitTable+template), h2 CODE
# (functab + strings). fixup.py restores the original RELOC32
# grouping/order.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = queue.library

all: $(TARGET)

$(TARGET): queue_h0.o queue_h1.o queue_h2.o fixup.py
	printf 'SECTIONS { .h0 : { queue_h0.o(.text) } .data : { queue_h1.o(.data) } .h2 : { queue_h2.o(.text) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) queue_h0.o queue_h1.o queue_h2.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

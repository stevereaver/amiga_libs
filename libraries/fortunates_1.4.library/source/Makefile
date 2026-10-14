# Makefile for fortunates.library 1.4 reconstruction.
# Three hunks: h0 CODE (RomTag+InitTable+17-vector functab+code),
# h1 DATA ("Select a file.." title string), h2 BSS (152B globals).
# fixup.py rewrites hunk0's RELOC32 records in the original
# group order (h0, h1, h2 targets).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = fortunates.library
OBJS    = fortunates_h0.o fortunates_h1.o fortunates_h2.o

all: $(TARGET)

$(TARGET): $(OBJS) fixup.py
	printf 'SECTIONS { .h0 : { fortunates_h0.o(.text) } .h1 : { fortunates_h1.o(.data) } .h2 : { fortunates_h2.o(.bss) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) $(OBJS)
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o hunks.x $(TARGET)

.PHONY: all clean

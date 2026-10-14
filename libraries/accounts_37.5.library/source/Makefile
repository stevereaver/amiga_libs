# Makefile for accounts.library 37.5 reconstruction.
# Single CODE hunk (code + strings + tables, 0xa70 bytes).
# fixup.py restores the original RELOC32 offset order
# (0xa before 0x6 -- EndSkip reloc emitted before MatchTag).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = accounts.library

all: $(TARGET)

$(TARGET): accounts.o fixup.py
	$(CC) $(LDFLAGS) -o $(TARGET) accounts.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

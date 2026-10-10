# Makefile for ted.library 1.0 reconstruction
#
# Single-code-hunk module, all assembly (code-hunk globals are
# addressed absolutely, as in the shipped binary).  Single pass.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = ted.library

all: $(TARGET)

$(TARGET): ted_lib.o
	$(CC) $(LDFLAGS) -o $@ ted_lib.o

ted_lib.o: ted_lib.s
	$(CC) $(ASFLAGS) -c -o $@ ted_lib.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

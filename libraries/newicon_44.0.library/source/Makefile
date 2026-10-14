# Makefile for newicon.library 44.0 emulation reconstruction
# Single-pass link: the original uses an absolute functab in a DATA
# hunk with relocations, so plain .long entries work.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
AS      = /opt/amiga/bin/m68k-amigaos-as
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -s

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

TARGET  = newicon.library

all: $(TARGET)

$(TARGET): newicon_lib.o newicon.o
	$(CC) $(LDFLAGS) -o $@ newicon_lib.o newicon.o

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

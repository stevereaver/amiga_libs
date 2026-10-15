# Makefile for xpkCYB1.library 1.0 -- byte-identical rebuild.
# `make`        -> rebuilds from xpkCYB1_h0.s (verbatim transcription).
#                  The original's RELOC32 tail is already in ascending
#                  order, so no fixup pass is needed.
# `make cmodel` -> earlier C model (kept for reference, NOT identical)
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = xpkCYB1.library
ORIG    = ../binary/xpkCYB1_1.0.library

all: $(TARGET)

$(TARGET): xpkCYB1_h0.o
	$(CC) $(LDFLAGS) -o $@ xpkCYB1_h0.o
	cmp -l $@ $(ORIG) && echo BYTE-IDENTICAL

xpkCYB1_h0.o: xpkCYB1_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

# --- reference C model (not byte-identical) ----------------------
cmodel: xpkCYB1_lib.o xpkCYB1.o
	$(CC) -nostdlib -nostartfiles -o xpkCYB1-c.library xpkCYB1_lib.o xpkCYB1.o

xpkCYB1_lib.o: xpkCYB1_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkCYB1_lib.s

xpkCYB1.o: xpkCYB1.c
	$(CC) $(CFLAGS) -c -o $@ xpkCYB1.c

clean:
	rm -f *.o $(TARGET) xpkCYB1-c.library

.PHONY: all cmodel clean

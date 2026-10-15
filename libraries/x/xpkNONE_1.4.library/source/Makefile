# Makefile for xpkNONE.library 1.4 reconstruction.
#
# `make`        -> byte-identical rebuild from xpkNONE_v.s + fixup.py
#                  (fixup rewrites GNU ld's ascending RELOC32 into the
#                  original's descending order AND adds the three
#                   in-idstring reloc records at 0xb6/0xba/0xbe)
# `make cmodel` -> earlier C-model build (not byte-identical)

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = xpkNONE.library

all: $(TARGET)

$(TARGET): xpkNONE_v.o fixup.py
	$(CC) $(LDFLAGS) -o $(TARGET) xpkNONE_v.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

# --- earlier C model ---
cmodel: xpknone_lib.o xpknone.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o xpkNONE-c.library $^

clean:
	rm -f *.o $(TARGET) xpkNONE-c.library dummy.library dummy.nm

.PHONY: all cmodel clean

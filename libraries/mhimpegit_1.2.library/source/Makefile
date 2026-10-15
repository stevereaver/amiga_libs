# Makefile for mhimpegit.library 1.2 (20.01.2017)
#
# Default target: byte-verbatim asm reconstruction (mhimpegit_h0.s)
# -- both hunks (CODE + DATA) in one file.  fixup.py rewrites the
# RELOC32 tails to the shipped binary's order (descending offsets,
# hunk0-target group first in the DATA hunk's tail).
#
# `make cmodel` builds the earlier C reconstruction
# (mhimpegit.c + mhimpegit_lib.s) -- same layout, GCC codegen differs.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

ORIG    = ../binary/mhimpegit_1.2.library
TARGET  = mhimpegit.library

all: verify

$(TARGET): mhimpegit_h0.o fixup.py
	$(CC) $(LDFLAGS) -o $@ mhimpegit_h0.o
	python3 fixup.py $@ "$(ORIG)"

verify: $(TARGET)
	@cmp -s "$(ORIG)" $(TARGET) && echo BYTE-IDENTICAL || echo "DIFFERS (see work/)"

mhimpegit_h0.o: mhimpegit_h0.s
	$(CC) $(ASFLAGS) -c -o $@ mhimpegit_h0.s

# --- earlier C reconstruction (kept for reference) ---------------

cmodel: mhimpegit_c.library

mhimpegit_c.library: mhimpegit_lib.o mhimpegit.o
	$(CC) -nostdlib -nostartfiles -o $@ mhimpegit_lib.o mhimpegit.o

mhimpegit_lib.o: mhimpegit_lib.s
	$(CC) -m68020 -c -o $@ mhimpegit_lib.s

mhimpegit.o: mhimpegit.c
	$(CC) $(CFLAGS) -c -o $@ mhimpegit.c

clean:
	rm -f *.o $(TARGET) mhimpegit_c.library

.PHONY: all verify cmodel clean

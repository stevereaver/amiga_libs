# Makefile for 68030.library 40.1 (MMU) (MMU.lib)
#
# Default: byte-verbatim assembly reconstruction (68030_h0.s --
# hunk0 .text + hunk1 .data in one file).  `make` builds, runs
# fixup.py to splice the original RELOC32 tails (the shipped
# binary's reloc order is the multi-object link order, not the
# ascending order GNU ld emits), and verifies against ../binary.
#
# `make cmodel` builds the earlier C reconstruction (68030.c +
# 68030_patch.s + 68030_lib.s) -- semantically equivalent, not
# byte-identical.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68030 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68030 -m68881
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = 68030.library

all: $(TARGET) verify

$(TARGET): 68030_h0.o
	$(CC) $(LDFLAGS) -o $@ $<
	python3 fixup.py $@ '../binary/68030_40.1(MMU).library'

68030_h0.o: 68030_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

# --- reference C model (not byte-identical) ----------------------
cmodel: 68030_lib.o 68030_patch.o 68030.o
	$(CC) -nostdlib -nostartfiles -o $(TARGET)-c \
		68030_lib.o 68030_patch.o 68030.o

68030_lib.o: 68030_lib.s
	$(CC) $(ASFLAGS) -c -o $@ 68030_lib.s

68030_patch.o: 68030_patch.s
	$(CC) $(ASFLAGS) -c -o $@ 68030_patch.s

68030.o: 68030.c
	$(CC) $(CFLAGS) -c -o $@ 68030.c

verify:
	@cmp -s $(TARGET) '../binary/68030_40.1(MMU).library' && echo BYTE-IDENTICAL \
	  || echo "DIFFERS (see work/)"

clean:
	rm -f *.o *.nm $(TARGET) $(TARGET)-c

.PHONY: all cmodel verify clean

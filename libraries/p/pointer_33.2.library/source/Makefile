# Makefile for pointer.library 33.2 C reconstruction
#
# Three-hunk target: CODE + DATA|CHIP + DATA.  The AmigaDev linker
# emits .datachip as a plain data hunk without the MEMF_CHIP flag, so
# the build (a) generates a linker script ordering .datachip before
# .data -- reproducing the original code/chip/data hunk order -- and
# (b) post-patches the MEMF_CHIP flag bit into the chip hunk's size
# entry and type word.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
SYSLD   = /opt/amiga/m68k-amigaos/lib/ldscripts/amiga.x

TARGET  = pointer.library

all: $(TARGET)

amiga_chip.x: $(SYSLD)
	python3 genscript.py $(SYSLD) > $@

pointer_lib.o: pointer_lib.s
	$(CC) $(ASFLAGS) -c -o $@ pointer_lib.s

pointer.o: pointer.c
	$(CC) $(CFLAGS) -c -o $@ pointer.c

$(TARGET): amiga_chip.x pointer_lib.o pointer.o
	$(CC) -nostdlib -nostartfiles -T amiga_chip.x \
		-o $@ pointer_lib.o pointer.o
	python3 chipflag.py $@

clean:
	rm -f *.o *.library amiga_chip.x

.PHONY: all clean

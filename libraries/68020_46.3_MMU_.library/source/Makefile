# Makefile for 68020.library 46.3 (MMU) (MMU.lib) C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
#
# The AUTOINIT function table holds absolute longword pointers, so a
# single link pass suffices -- gas/ld emit the HUNK_RELOC32 entries
# for the .long vector entries directly.
#
# 68020_patch.s is required asm: the patch region contains the vector
# stubs, supervisor-mode code (movec vbr, pmove tc, rte), the
# hardware INTENA GetMsg replacement, the 68881 fsave-frame fixup and
# the 46.3 init helpers (mmu.library calls, p5emu expunge), none of
# which are expressible in C.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020 -m68851 -m68881
LDFLAGS = -nostdlib -nostartfiles

TARGET  = 68020.library

all: $(TARGET)

$(TARGET): 68020_lib.o 68020_patch.o 68020.o
	$(CC) $(LDFLAGS) -o $@ 68020_lib.o 68020_patch.o 68020.o

68020_lib.o: 68020_lib.s
	$(CC) $(ASFLAGS) -c -o $@ 68020_lib.s

68020_patch.o: 68020_patch.s
	$(CC) $(ASFLAGS) -c -o $@ 68020_patch.s

68020.o: 68020.c
	$(CC) $(CFLAGS) -c -o $@ 68020.c

clean:
	rm -f *.o *.nm $(TARGET)

.PHONY: all clean

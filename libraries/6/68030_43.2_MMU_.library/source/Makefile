# Makefile for 68030.library 43.2 (MMU) (MMU.lib) C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
#
# The AUTOINIT function table holds absolute longword pointers, so a
# single link pass suffices -- gas/ld emit the HUNK_RELOC32 entries
# for the .long vector entries directly.
#
# 68030_patch.s is required asm: the patch region contains the vector
# stubs, supervisor-mode code (movec vbr, pmove tc, rte), the
# hardware INTENA GetMsg replacement and the 68881 fsave-frame fixup,
# none of which are expressible in C.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68030 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68030 -m68881
LDFLAGS = -nostdlib -nostartfiles

TARGET  = 68030.library

all: $(TARGET)

$(TARGET): 68030_lib.o 68030_patch.o 68030.o
	$(CC) $(LDFLAGS) -o $@ 68030_lib.o 68030_patch.o 68030.o

68030_lib.o: 68030_lib.s
	$(CC) $(ASFLAGS) -c -o $@ 68030_lib.s

68030_patch.o: 68030_patch.s
	$(CC) $(ASFLAGS) -c -o $@ 68030_patch.s

68030.o: 68030.c
	$(CC) $(CFLAGS) -c -o $@ 68030.c

clean:
	rm -f *.o *.nm $(TARGET)

.PHONY: all clean

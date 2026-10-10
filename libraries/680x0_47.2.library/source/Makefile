# Makefile for 680x0.library 47.2 (MMU.lib) C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
#
# The AUTOINIT function table holds absolute longword pointers, so a
# single link pass suffices -- gas/ld emit the HUNK_RELOC32 entries
# for the .long vector entries directly (same scheme as
# version_37.67).  No genfunctab.py second pass is needed.
#
# cpuprobe.s is required asm: the 68060 check runs in supervisor
# state, redirects the VBR at a fake stack-based vector table and
# executes a "movec pcr" that only the 68060 supports.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles

TARGET  = 680x0.library

all: $(TARGET)

$(TARGET): 680x0_lib.o cpuprobe.o 680x0.o
	$(CC) $(LDFLAGS) -o $@ 680x0_lib.o cpuprobe.o 680x0.o

680x0_lib.o: 680x0_lib.s
	$(CC) $(ASFLAGS) -c -o $@ 680x0_lib.s

cpuprobe.o: cpuprobe.s
	$(CC) $(ASFLAGS) -c -o $@ cpuprobe.s

680x0.o: 680x0.c
	$(CC) $(CFLAGS) -c -o $@ 680x0.c

clean:
	rm -f *.o *.nm $(TARGET)

.PHONY: all clean

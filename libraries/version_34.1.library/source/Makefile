# Makefile for version.library 34.1 C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
#
# Unlike iffparse.library (which uses a word-offset AUTOINIT table),
# this binary's function table holds absolute longword pointers, so a
# single link pass suffices -- gas/ld emit the HUNK_RELOC32 entries for
# the .long vector entries directly.  No genfunctab.py second pass is
# needed.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = version.library

all: $(TARGET)

$(TARGET): version_lib.o version.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ version_lib.o version.o endmodule.o

version_lib.o: version_lib.s
	$(CC) $(ASFLAGS) -c -o $@ version_lib.s

version.o: version.c
	$(CC) $(CFLAGS) -c -o $@ version.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o *.nm $(TARGET)

.PHONY: all clean

# Makefile for fwfiltertype.library 3.0 (SoftWood 1993) C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# Absolute-longword function table -> single link pass, no genfunctab.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = fwfiltertype.library

all: $(TARGET)

$(TARGET): fwfiltertype_lib.o fwfiltertype.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ fwfiltertype_lib.o fwfiltertype.o endmodule.o

fwfiltertype_lib.o: fwfiltertype_lib.s
	$(CC) $(ASFLAGS) -c -o $@ fwfiltertype_lib.s

fwfiltertype.o: fwfiltertype.c fwbase.h
	$(CC) $(CFLAGS) -c -o $@ fwfiltertype.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o *.nm $(TARGET)

.PHONY: all clean

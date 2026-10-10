# Makefile for asdg-low-mem.library (10-Jun-87) C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# Absolute-longword AUTOINIT function table -> single link pass.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = asdg-low-mem.library

all: $(TARGET)

$(TARGET): lowmem_lib.o lowmem.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ lowmem_lib.o lowmem.o endmodule.o

lowmem_lib.o: lowmem_lib.s
	$(CC) $(ASFLAGS) -c -o $@ lowmem_lib.s

lowmem.o: lowmem.c
	$(CC) $(CFLAGS) -c -o $@ lowmem.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

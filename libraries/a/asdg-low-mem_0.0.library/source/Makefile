# Makefile for asdg-low-mem.library (10-Jun-87)
#
# Default target: byte-verbatim reconstruction in asdg_h0.s.
# `cmodel` builds the historical C reconstruction instead.
# fixup.py rewrites the linked single-hunk file into the
# original's 3-hunk envelope (CODE + empty DATA + empty BSS).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = asdg-low-mem.library

all: $(TARGET)

$(TARGET): asdg_h0.o fixup.py
	$(CC) $(LDFLAGS) -o asdg_1hunk.library asdg_h0.o
	python3 fixup.py asdg_1hunk.library $(TARGET)

asdg_h0.o: asdg_h0.s
	$(CC) $(ASFLAGS) -c -o $@ asdg_h0.s

cmodel: lowmem_lib.o lowmem.o endmodule.o
	$(CC) $(LDFLAGS) -o $(TARGET) lowmem_lib.o lowmem.o endmodule.o

lowmem_lib.o: lowmem_lib.s
	$(CC) $(ASFLAGS) -c -o $@ lowmem_lib.s

lowmem.o: lowmem.c
	$(CC) $(CFLAGS) -c -o $@ lowmem.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o $(TARGET) asdg_1hunk.library

.PHONY: all cmodel clean

# Makefile for wbstart.library 45.1 (16.12.00)
#
# Default target: verbatim asm reconstruction (wbstart_h0.s),
# byte-identical to the shipped binary after fixup.py rewrites
# GNU ld's HUNK_RELOC32 tail into the shipped HUNK_DREL32
# (word-offset) form.
#
# `make cmodel` builds the earlier C reconstruction
# (wbstart_c.library) -- same layout, GCC codegen differs.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

ORIG    = ../binary/wbstart_45.1.library
TARGET  = wbstart.library

all: verify

$(TARGET): wbstart_h0.o fixup.py
	$(CC) $(LDFLAGS) -o $@ wbstart_h0.o
	python3 fixup.py $@ "$(ORIG)"

verify: $(TARGET)
	cmp "$(ORIG)" $(TARGET) && echo "byte-identical"

wbstart_h0.o: wbstart_h0.s
	$(CC) $(ASFLAGS) -c -o $@ wbstart_h0.s

# --- earlier C reconstruction (kept for reference) ---------------

cmodel: wbstart_c.library

wbstart_c.library: wbstart_lib.o wbstart.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o $@ wbstart_lib.o wbstart.o endmodule.o

wbstart_lib.o: wbstart_lib.s
	$(CC) $(ASFLAGS) -c -o $@ wbstart_lib.s

wbstart.o: wbstart.c
	$(CC) $(CFLAGS) -c -o $@ wbstart.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o $(TARGET) wbstart_c.library

.PHONY: all verify cmodel clean

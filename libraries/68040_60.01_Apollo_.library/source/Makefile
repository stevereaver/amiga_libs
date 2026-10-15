# Makefile for the Apollo 68040.library 60.01 loader stub
#
# `make`        -> byte-identical rebuild from 68040.s
# `make cmodel` -> earlier C-model build (functionally equivalent,
#                  not byte-identical; kept as semantic reference)
#
# The AUTOINIT function table holds absolute longword pointers, so a
# single link pass suffices -- gas/ld emit the HUNK_RELOC32 entries
# for the .long vector entries directly.  -Wl,-s keeps symbol/debug
# hunks out of the output.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = 68040.library

all: $(TARGET)

$(TARGET): 68040.o
	$(CC) $(LDFLAGS) -Wl,-s -o $@ 68040.o

68040.o: 68040.s
	$(CC) $(ASFLAGS) -c -o $@ 68040.s

# --- earlier C model (semantic reference, not byte-identical) ---
cmodel: loader_lib.o loader.o endmodule.o
	$(CC) $(LDFLAGS) -o 68040-c.library loader_lib.o loader.o endmodule.o

loader_lib.o: loader_lib.s
	$(CC) -m68040 -c -o $@ loader_lib.s

loader.o: loader.c
	$(CC) $(CFLAGS) -c -o $@ loader.c

endmodule.o: endmodule.s
	$(CC) -m68040 -c -o $@ endmodule.s

clean:
	rm -f *.o 68040-c.library $(TARGET)

.PHONY: all cmodel clean

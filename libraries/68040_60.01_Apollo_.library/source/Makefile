# Makefile for the Apollo 68040.library 60.01 loader stub
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
#
# Unlike iffparse (which uses a word-offset AUTOINIT function table
# and therefore needs the genfunctab.py two-pass trick), this library
# uses an absolute-long function table: plain .long entries in
# loader_lib.s produce the same RELOC32 hunks as the original binary,
# so no second pass is required.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68040
LDFLAGS = -nostdlib -nostartfiles

TARGET  = 68040.library

all: $(TARGET)

$(TARGET): loader_lib.o loader.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ loader_lib.o loader.o endmodule.o

loader_lib.o: loader_lib.s
	$(CC) $(ASFLAGS) -c -o $@ loader_lib.s

loader.o: loader.c
	$(CC) $(CFLAGS) -c -o $@ loader.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

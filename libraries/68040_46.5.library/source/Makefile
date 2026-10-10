# Makefile for the Phase5 68040.library 46.5 loader stub
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# The AUTOINIT function table is absolute-long (.long entries in
# loader_lib.s), so no two-pass functab generation is needed.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68040
LDFLAGS = -nostdlib -nostartfiles

TARGET  = 68040.library

all: $(TARGET)

$(TARGET): loader_lib.o loader.o helpers.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ loader_lib.o loader.o helpers.o endmodule.o

loader_lib.o: loader_lib.s
	$(CC) $(ASFLAGS) -c -o $@ loader_lib.s

loader.o: loader.c
	$(CC) $(CFLAGS) -c -o $@ loader.c

helpers.o: helpers.s
	$(CC) $(ASFLAGS) -c -o $@ helpers.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

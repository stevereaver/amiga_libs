# Makefile for xpkNONE.library 1.4 (19.07.1998) C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# Absolute-longword function table -> single link pass, no genfunctab.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkNONE.library

all: $(TARGET)

$(TARGET): xpknone_lib.o xpknone.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpknone_lib.o xpknone.o endmodule.o

xpknone_lib.o: xpknone_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpknone_lib.s

xpknone.o: xpknone.c xpkbase.h
	$(CC) $(CFLAGS) -c -o $@ xpknone.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

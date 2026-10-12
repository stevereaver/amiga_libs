# Makefile for xpkMASH.library 1.16 C reconstruction
#
# Single code hunk; functab = long offsets relative to _start, so no
# two-pass offset generation is needed.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkMASH.library
OBJS    = xpkMASH_lib.o xpkMASH.o endmodule.o

all: $(TARGET)

xpkMASH_lib.o: xpkMASH_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkMASH_lib.s

xpkMASH.o: xpkMASH.c
	$(CC) $(CFLAGS) -c -o $@ xpkMASH.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

clean:
	rm -f *.o *.library

.PHONY: all clean

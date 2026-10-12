# Makefile for xpkHFMN.library 1.36 (68020+) C reconstruction
#
# Single code hunk; functab = long offsets relative to _start, so no
# two-pass offset generation is needed.  Built -m68020: the original
# gates on AFB_68020 and uses bfins/bfextu + scaled indexing.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkHFMN.library
OBJS    = xpkHFMN_lib.o xpkHFMN.o endmodule.o

all: $(TARGET)

xpkHFMN_lib.o: xpkHFMN_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkHFMN_lib.s

xpkHFMN.o: xpkHFMN.c
	$(CC) $(CFLAGS) -c -o $@ xpkHFMN.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

clean:
	rm -f *.o *.library

.PHONY: all clean

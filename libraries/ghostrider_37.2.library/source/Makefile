# Makefile for GhostRider.library 37.2 C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# Absolute-longword AUTOINIT functab -- single link pass.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = ghostrider.library

all: $(TARGET)

OBJS = ghostrider_lib.o ghostrider.o endmodule.o

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

ghostrider_lib.o: ghostrider_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ $<

ghostrider.o: ghostrider.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

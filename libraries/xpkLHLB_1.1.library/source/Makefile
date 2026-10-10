# Makefile for xpkLHLB.library V1.1 C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross
# toolchain.  Absolute-longword AUTOINIT functab -- single
# link pass.  Requires lh.library on the target system.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkLHLB.library

all: $(TARGET)

OBJS = xpkLHLB_lib.o xpkLHLB.o

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

xpkLHLB_lib.o: xpkLHLB_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

xpkLHLB.o: xpkLHLB.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

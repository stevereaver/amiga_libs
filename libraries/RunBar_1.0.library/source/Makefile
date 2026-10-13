# Makefile for RunBar.library 1.0 C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# Absolute-longword AUTOINIT function table: single link pass.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = RunBar.library

all: $(TARGET)

$(TARGET): runbar_lib.o runbar.o
	$(CC) $(LDFLAGS) -o $@ runbar_lib.o runbar.o

runbar_lib.o: runbar_lib.s
	$(CC) $(ASFLAGS) -c -o $@ runbar_lib.s

runbar.o: runbar.c
	$(CC) $(CFLAGS) -c -o $@ runbar.c

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

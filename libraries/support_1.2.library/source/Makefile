# Makefile for support.library 1.2 C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles

TARGET  = support.library

all: $(TARGET)

$(TARGET): support_lib.o support.o support_end.o
	$(CC) $(LDFLAGS) -o $@ support_lib.o support.o support_end.o

support_lib.o: support_lib.s
	$(CC) $(ASFLAGS) -c -o $@ support_lib.s

support.o: support.c
	$(CC) $(CFLAGS) -c -o $@ support.c

support_end.o: support_end.s
	$(CC) $(ASFLAGS) -c -o $@ support_end.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

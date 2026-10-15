# Makefile for intuisupport.library 1.1 C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# Absolute-longword AUTOINIT function table: single link pass.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = intuisupport.library

all: $(TARGET)

$(TARGET): intuisupport_lib.o intuisupport.o
	$(CC) $(LDFLAGS) -o $@ intuisupport_lib.o intuisupport.o

intuisupport_lib.o: intuisupport_lib.s
	$(CC) $(ASFLAGS) -c -o $@ intuisupport_lib.s

intuisupport.o: intuisupport.c
	$(CC) $(CFLAGS) -c -o $@ intuisupport.c

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

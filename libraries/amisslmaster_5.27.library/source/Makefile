# Makefile for amisslmaster.library 5.27 reconstruction -- 68000 build
#
# Original is compiled C (stack args).  Absolute-long functab lives in
# the DATA hunk (_mFuncTable in .data).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -s

TARGET  = amisslmaster.library

all: $(TARGET)

amisslmaster_lib.o: amisslmaster_lib.s
	$(CC) $(ASFLAGS) -c -o $@ amisslmaster_lib.s

amisslmaster.o: amisslmaster.c
	$(CC) $(CFLAGS) -c -o $@ amisslmaster.c

$(TARGET): amisslmaster_lib.o amisslmaster.o
	$(CC) $(LDFLAGS) -o $@ amisslmaster_lib.o amisslmaster.o

clean:
	rm -f *.o *.library

.PHONY: all clean

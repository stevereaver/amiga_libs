# Makefile for utility.library 41.0 C reconstruction
#
# Word-offset functab: entries are .word (func - functab), computed
# at assembly time — no second pass needed.
# utility_lib.o must link first so the RomTag lands at hunk+0.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020 -m68881
LDFLAGS = -nostdlib -nostartfiles

TARGET  = utility.library

all: $(TARGET)

utility_lib.o: utility_lib.s
	$(CC) $(ASFLAGS) -c -o $@ utility_lib.s

utility.o: utility.c
	$(CC) $(CFLAGS) -c -o $@ utility.c

utility_end.o: utility_end.s
	$(CC) $(ASFLAGS) -c -o $@ utility_end.s

$(TARGET): utility_lib.o utility.o utility_end.o
	$(CC) $(LDFLAGS) -o $@ utility_lib.o utility.o utility_end.o

clean:
	rm -f *.o *.nm *.library

.PHONY: all clean

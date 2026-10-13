# Makefile for xpksqsh.library 1.10(older) C reconstruction
#
# Absolute-longword functab (10 entries) -- no offset generation pass.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin -fno-strict-aliasing \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkSQSH.library

all: $(TARGET)

xpkSQSH_lib.o: xpkSQSH_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkSQSH_lib.s

xpkSQSH.o: xpkSQSH.c
	$(CC) $(CFLAGS) -c -o $@ xpkSQSH.c

$(TARGET): xpkSQSH_lib.o xpkSQSH.o
	$(CC) $(LDFLAGS) -o $@ xpkSQSH_lib.o xpkSQSH.o

clean:
	rm -f *.o *.library

.PHONY: all clean

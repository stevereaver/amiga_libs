# Makefile for xpkNONE.library 1.5 reconstruction.
# `make`        -> byte-identical rebuild from xpkNONE_h0.s
# `make cmodel` -> earlier C model (documentation, not byte-identical)
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = xpkNONE.library
ORIG    = '../binary/xpkNONE_1.5(000).library'

all: $(TARGET)

$(TARGET): xpkNONE_h0.o
	$(CC) $(LDFLAGS) -o $(TARGET) xpkNONE_h0.o
	cmp -l $(TARGET) $(ORIG) && echo BYTE-IDENTICAL

xpkNONE_h0.o: xpkNONE_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

cmodel: xpkNONE_lib.o functab.o xpkNONE.o
	$(CC) $(LDFLAGS) -o xpkNONE-c.library xpkNONE_lib.o functab.o xpkNONE.o

xpkNONE.o: xpkNONE.c
	$(CC) $(CFLAGS) -c -o $@ xpkNONE.c

clean:
	rm -f *.o xpkNONE-c.library $(TARGET)

.PHONY: all cmodel clean

# Makefile for xpkNONE.library 1.2
#
# Default target builds the byte-identical verbatim assembly
# reconstruction (xpkNONE_v.s + fixup.py reorders the reloc tail
# to the original's descending order).
# `make cmodel` builds the older readable C model (NOT byte-identical).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

ORIG    = ../binary/xpkNONE_1.2.library
TARGET  = xpkNONE.library

all: $(TARGET)

$(TARGET): xpkNONE_v.o
	$(CC) $(LDFLAGS) -Wl,-s -o $@ xpkNONE_v.o
	python3 fixup.py $(TARGET) $(ORIG)

xpkNONE_v.o: xpkNONE_v.s
	$(CC) $(ASFLAGS) -c -o $@ xpkNONE_v.s

cmodel:
	$(CC) $(ASFLAGS) -c -o xpkNONE_lib.o xpkNONE_lib.s
	$(CC) $(CFLAGS)  -c -o xpkNONE.o xpkNONE.c
	$(CC) $(LDFLAGS) -o xpkNONE_cmodel.library xpkNONE_lib.o xpkNONE.o

clean:
	rm -f *.o $(TARGET) xpkNONE_cmodel.library

.PHONY: all clean cmodel

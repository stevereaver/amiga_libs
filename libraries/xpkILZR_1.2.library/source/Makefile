# Makefile for xpkILZR.library 1.2 C reconstruction
#
# Two-pass word-offset functab: link a dummy image with a
# size-correct functab_stub.o, measure the final .text addresses,
# then generate functab.s with the real offsets.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = xpkILZR.library

all: $(TARGET)

dummy.library: xpkILZR_lib.o functab_stub.o xpkILZR.o
	$(CC) $(LDFLAGS) -o $@ xpkILZR_lib.o functab_stub.o xpkILZR.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

xpkILZR_lib.o: xpkILZR_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkILZR_lib.s

xpkILZR.o: xpkILZR.c
	$(CC) $(CFLAGS) -c -o $@ xpkILZR.c

$(TARGET): xpkILZR_lib.o functab.o xpkILZR.o
	$(CC) $(LDFLAGS) -o $@ xpkILZR_lib.o functab.o xpkILZR.o

clean:
	rm -f *.o *.nm *.library dummy.library functab.s

.PHONY: all clean

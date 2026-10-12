# Makefile for xpkMASH.library 2.0(020) C reconstruction
#
# Two-pass word-offset functab: link a dummy image with a
# size-correct functab_stub.o, measure the final .text addresses,
# then generate functab.s with the real offsets.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = xpkMASH.library

all: $(TARGET)

dummy.library: xpkMASH_lib.o functab_stub.o xpkMASH.o
	$(CC) $(LDFLAGS) -o $@ xpkMASH_lib.o functab_stub.o xpkMASH.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

xpkMASH_lib.o: xpkMASH_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkMASH_lib.s

xpkMASH.o: xpkMASH.c
	$(CC) $(CFLAGS) -c -o $@ xpkMASH.c

$(TARGET): xpkMASH_lib.o functab.o xpkMASH.o
	$(CC) $(LDFLAGS) -o $@ xpkMASH_lib.o functab.o xpkMASH.o

clean:
	rm -f *.o *.nm *.library dummy.library functab.s

.PHONY: all clean

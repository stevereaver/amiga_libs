# Makefile for xpkHFMN.library 1.4 C reconstruction
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

TARGET  = xpkHFMN.library

all: $(TARGET)

dummy.library: xpkHFMN_lib.o functab_stub.o xpkHFMN.o
	$(CC) $(LDFLAGS) -o $@ xpkHFMN_lib.o functab_stub.o xpkHFMN.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

xpkHFMN_lib.o: xpkHFMN_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkHFMN_lib.s

xpkHFMN.o: xpkHFMN.c
	$(CC) $(CFLAGS) -c -o $@ xpkHFMN.c

$(TARGET): xpkHFMN_lib.o functab.o xpkHFMN.o
	$(CC) $(LDFLAGS) -o $@ xpkHFMN_lib.o functab.o xpkHFMN.o

clean:
	rm -f *.o *.nm *.library dummy.library functab.s

.PHONY: all clean

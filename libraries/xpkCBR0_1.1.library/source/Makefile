# Makefile for xpkCBR0.library v1.1 -- byte-identical rebuild.
# `make`        -> rebuilds from xpkCBR0_h0.s (verbatim transcription),
#                  then fixup.py rewrites the RELOC32 tail to the
#                  original's DESCENDING order.
# `make cmodel` -> earlier C model (kept for reference, NOT identical)
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = xpkCBR0.library
ORIG    = ../binary/xpkCBR0_1.1.library

all: $(TARGET)

$(TARGET): xpkCBR0_h0.o fixup.py
	$(CC) $(LDFLAGS) -o $@ xpkCBR0_h0.o
	python3 fixup.py $@
	cmp -l $@ $(ORIG) && echo BYTE-IDENTICAL

xpkCBR0_h0.o: xpkCBR0_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

# --- reference C model (not byte-identical) ----------------------
cmodel: xpkCBR0_lib.o functab.o xpkCBR0.o
	$(CC) -nostdlib -nostartfiles -o xpkCBR0-c.library xpkCBR0_lib.o functab.o xpkCBR0.o

dummy.library: xpkCBR0_lib.o functab_stub.o xpkCBR0.o
	$(CC) -nostdlib -nostartfiles -o $@ xpkCBR0_lib.o functab_stub.o xpkCBR0.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

xpkCBR0.o: xpkCBR0.c
	$(CC) $(CFLAGS) -c -o $@ xpkCBR0.c

clean:
	rm -f *.o *.nm functab.s dummy.library xpkCBR0-c.library $(TARGET)

.PHONY: all cmodel clean

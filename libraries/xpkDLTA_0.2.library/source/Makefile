# Makefile for xpkDLTA.library v0.2 -- byte-identical rebuild.
# `make`        -> rebuilds from xpkDLTA_h0.s, then fixup.py rewrites
#                  the reloc32 tail to the original descending order
# `make cmodel` -> earlier C model (kept for reference, NOT identical)
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
LDSYM   = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = xpkDLTA.library
ORIG    = '../binary/xpkDLTA_0.2.library'

all: $(TARGET)

$(TARGET): xpkDLTA_h0.o fixup.py
	$(CC) $(LDFLAGS) -o $(TARGET) xpkDLTA_h0.o
	python3 fixup.py $(TARGET)
	cmp -l $(TARGET) $(ORIG) && echo BYTE-IDENTICAL

xpkDLTA_h0.o: xpkDLTA_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

# --- reference C model (not byte-identical) ----------------------
cmodel: xpkDLTA_lib.o functab.o xpkDLTA.o
	$(CC) $(LDSYM) -o xpkDLTA-c.library xpkDLTA_lib.o functab.o xpkDLTA.o

dummy.library: xpkDLTA_lib.o functab_stub.o xpkDLTA.o
	$(CC) $(LDSYM) -o $@ xpkDLTA_lib.o functab_stub.o xpkDLTA.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

xpkDLTA.o: xpkDLTA.c
	$(CC) $(CFLAGS) -c -o $@ xpkDLTA.c

clean:
	rm -f *.o *.nm functab.s dummy.library xpkDLTA-c.library $(TARGET)

.PHONY: all cmodel clean

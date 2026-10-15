# Makefile for xpkRLEN.library 1.4 (1.12.2010) -- byte-identical rebuild.
#
# `make`        -> rebuilds from xpkRLEN_h0.s (verbatim asm), then
#                  fixup.py rewrites the RELOC32 tail to the original's
#                  descending order and verifies against ../binary/.
# `make cmodel` -> earlier C model (kept for reference, NOT identical).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
LDSYM   = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = xpkRLEN.library
ORIG    = ../binary/xpkRLEN_1.4.library

all: $(TARGET)

$(TARGET): xpkRLEN_h0.o fixup.py
	$(CC) $(LDFLAGS) -o $(TARGET) xpkRLEN_h0.o
	python3 fixup.py $(TARGET)
	cmp -l $(TARGET) $(ORIG) && echo BYTE-IDENTICAL

xpkRLEN_h0.o: xpkRLEN_h0.s
	$(CC) $(ASFLAGS) -c -o $@ xpkRLEN_h0.s

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

# --- reference C model (not byte-identical) ----------------------
cmodel: xpkRLEN_c.library

xpkRLEN_c.library: xpkRLEN_lib.o functab.o xpkRLEN.o endmodule.o
	$(CC) $(LDSYM) -o $@ xpkRLEN_lib.o functab.o xpkRLEN.o endmodule.o

dummy.library: xpkRLEN_lib.o functab_stub.o xpkRLEN.o endmodule.o
	$(CC) $(LDSYM) -o $@ xpkRLEN_lib.o functab_stub.o xpkRLEN.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

xpkRLEN.o: xpkRLEN.c
	$(CC) $(CFLAGS) -c -o $@ xpkRLEN.c

clean:
	rm -f *.o *.nm functab.s dummy.library xpkRLEN_c.library $(TARGET)

.PHONY: all cmodel clean

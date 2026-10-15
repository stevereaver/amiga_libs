# Makefile for mathieeedoubtrans.library "MDT 10.881" reconstruction.
#
# `make`        -> byte-identical rebuild from mathieeedoubtrans_h0.s
#                  (fixup.py rewrites GNU ld's RELOC32 tail into the
#                  original compact 16-bit 0x3f7 RELOC32SHORT chunk)
# `make cmodel` -> earlier C+asm model (functionally equivalent, NOT
#                  byte-identical; kept as semantic documentation)
#
# The AUTOINIT function table is a list of word offsets relative to
# the table start (a -1 flag word marks it).  In the verbatim h0.s it
# is expressed directly as `sym - _functab` .short entries; the C
# model still needs the two-pass genfunctab.py link below.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -Wa,-m68881 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000 -Wa,-m68881
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = mathieeedoubtrans.library
ORIG    = ../binary/mathieeedoubtrans_10.881.library

all: $(TARGET)

$(TARGET): mathieeedoubtrans_h0.o fixup.py
	$(CC) $(LDFLAGS) -Wl,-s -o $(TARGET) mathieeedoubtrans_h0.o
	python3 fixup.py $(TARGET) '$(ORIG)'

mathieeedoubtrans_h0.o: mathieeedoubtrans_h0.s
	$(CC) $(ASFLAGS) -c -o $@ mathieeedoubtrans_h0.s

# --- earlier C model (semantic documentation) ----------------------
cmodel: mathieeedoubtrans_lib.o functab.o datatab.o math.o mathieeedoubtrans.o endmodule.o
	$(CC) $(LDFLAGS) -o mathieeedoubtrans-c.library mathieeedoubtrans_lib.o \
		functab.o datatab.o math.o mathieeedoubtrans.o endmodule.o

# pass 1: dummy table (same size as the real one), just to learn the
# final addresses of every function in the code hunk.
dummy.library: mathieeedoubtrans_lib.o functab_stub.o datatab.o math.o mathieeedoubtrans.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ $^

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.nm functab.s dummy.library $(TARGET) mathieeedoubtrans-c.library

.PHONY: all cmodel clean

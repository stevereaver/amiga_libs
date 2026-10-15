# Makefile for mathieeesingtrans.library "MST 10.881" reconstruction.
#
# `make`        -> byte-identical rebuild from mathieeesingtrans.s
#                  (fixup.py rewrites GNU ld's RELOC32 tail into the
#                  original compact 16-bit 0x3f7 RELOC32SHORT chunk)
# `make cmodel` -> earlier C+asm model (functionally equivalent, not
#                  byte-identical; kept as semantic documentation)
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -Wa,-m68881 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000 -Wa,-m68881
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = mathieeesingtrans.library
ORIG    = ../binary/mathieeesingtrans_10.881.library

all: $(TARGET)

$(TARGET): mathieeesingtrans_v.o fixup.py
	$(CC) $(LDFLAGS) -Wl,-s -o $(TARGET) mathieeesingtrans_v.o
	python3 fixup.py $(TARGET) $(ORIG)

mathieeesingtrans_v.o: mathieeesingtrans.s
	$(CC) $(ASFLAGS) -c -o $@ mathieeesingtrans.s

# --- earlier C model (semantic documentation) ------------------------
cmodel: mathieeesingtrans_lib.o functab.o datatab.o math.o mathieeesingtrans.o endmodule.o
	$(CC) $(LDFLAGS) -o mathieeesingtrans-c.library mathieeesingtrans_lib.o \
		functab.o datatab.o math.o mathieeesingtrans.o endmodule.o

# pass 1: dummy table (same size as the real one), just to learn the
# final addresses of every function in the code hunk.
dummy.library: mathieeesingtrans_lib.o functab_stub.o datatab.o math.o mathieeesingtrans.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ mathieeesingtrans_lib.o functab_stub.o datatab.o math.o mathieeesingtrans.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

mathieeesingtrans.o: mathieeesingtrans.c
	$(CC) $(CFLAGS) -c -o $@ mathieeesingtrans.c

clean:
	rm -f *.o *.nm functab.s dummy.library mathieeesingtrans-c.library $(TARGET)

.PHONY: all cmodel clean

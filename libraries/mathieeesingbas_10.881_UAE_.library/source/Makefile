# Makefile for mathieeesingbas.library "MSB 10.881" reconstruction.
#
# `make`        -> byte-identical rebuild from mathieeesingbas.s
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

TARGET  = mathieeesingbas.library
ORIG    = ../binary/mathieeesingbas_10.881(UAE).library

all: $(TARGET)

$(TARGET): mathieeesingbas_v.o fixup.py
	$(CC) $(LDFLAGS) -Wl,-s -o $(TARGET) mathieeesingbas_v.o
	python3 fixup.py $(TARGET) '$(ORIG)'

mathieeesingbas_v.o: mathieeesingbas.s
	$(CC) $(ASFLAGS) -c -o $@ mathieeesingbas.s

# --- earlier C model (semantic documentation) ------------------------
cmodel: mathieeesingbas_lib.o functab.o datatab.o math.o mathieeesingbas.o endmodule.o
	$(CC) $(LDFLAGS) -o mathieeesingbas-c.library mathieeesingbas_lib.o \
		functab.o datatab.o math.o mathieeesingbas.o endmodule.o

# pass 1: dummy table (same size as the real one), just to learn the
# final addresses of every function in the code hunk.
dummy.library: mathieeesingbas_lib.o functab_stub.o datatab.o math.o mathieeesingbas.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ mathieeesingbas_lib.o functab_stub.o datatab.o math.o mathieeesingbas.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

mathieeesingbas.o: mathieeesingbas.c
	$(CC) $(CFLAGS) -c -o $@ mathieeesingbas.c

clean:
	rm -f *.o *.nm functab.s dummy.library mathieeesingbas-c.library $(TARGET)

.PHONY: all cmodel clean

# Makefile for mathieeesingbas.library "MSB 10.881" (UAE badge)
#
# `make`        -> byte-identical rebuild from mathieeesingbas.s
#                  (fixup.py rewrites the 0x3f7 DREL reloc tail that
#                  GNU ld cannot emit)
# `make cmodel` -> earlier C model (functionally equivalent, NOT
#                  byte-identical; kept as semantic documentation)
#
# The AUTOINIT function table is a list of word offsets relative to
# the table start (a -1 flag word marks it).  gas cannot express
# "extern_sym - local_sym" in a .word across objects, so the C model's
# table is generated in a second link pass: a dummy table of the right
# size is linked, symbol addresses are read with nm, and
# genfunctab.py emits the real .word values.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -Wa,-m68881 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000 -Wa,-m68881
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = mathieeesingbas.library

all: $(TARGET)

# --- byte-identical build ------------------------------------------------
$(TARGET): mathieeesingbas_byte.o fixup.py
	$(CC) $(LDFLAGS) -Wl,-s -o $@ mathieeesingbas_byte.o
	python3 fixup.py $@

mathieeesingbas_byte.o: mathieeesingbas.s
	$(CC) $(ASFLAGS) -c -o $@ mathieeesingbas.s

# --- earlier C model ------------------------------------------------------
cmodel: mathieeesingbas_lib.o functab.o datatab.o math.o mathieeesingbas.o endmodule.o
	$(CC) $(LDFLAGS) -o $(TARGET)-cmodel mathieeesingbas_lib.o functab.o \
		datatab.o math.o mathieeesingbas.o endmodule.o

# pass 1: dummy table (same size as the real one), just to learn the
# final addresses of every function in the code hunk.
dummy.library: mathieeesingbas_lib.o functab_stub.o datatab.o math.o mathieeesingbas.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ mathieeesingbas_lib.o functab_stub.o datatab.o math.o mathieeesingbas.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

mathieeesingbas_lib.o: mathieeesingbas_lib.s
	$(CC) $(ASFLAGS) -c -o $@ mathieeesingbas_lib.s

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

datatab.o: datatab.s
	$(CC) $(ASFLAGS) -c -o $@ datatab.s

math.o: math.s
	$(CC) $(ASFLAGS) -c -o $@ math.s

mathieeesingbas.o: mathieeesingbas.c
	$(CC) $(CFLAGS) -c -o $@ mathieeesingbas.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o *.nm functab.s dummy.library test.library $(TARGET) $(TARGET)-cmodel

.PHONY: all cmodel clean

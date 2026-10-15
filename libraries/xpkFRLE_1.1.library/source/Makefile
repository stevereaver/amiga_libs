# Makefile for xpkFRLE.library V1.1 -- byte-identical rebuild.
# `make`        -> rebuilds from xpkFRLE_h0.s (verbatim transcription),
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

TARGET  = xpkFRLE.library
ORIG    = ../binary/xpkFRLE_1.1.library

all: $(TARGET)

$(TARGET): xpkFRLE_h0.o fixup.py
	$(CC) $(LDFLAGS) -o $@ xpkFRLE_h0.o
	python3 fixup.py $@
	cmp -l $@ $(ORIG) && echo BYTE-IDENTICAL

xpkFRLE_h0.o: xpkFRLE_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

# --- reference C model (not byte-identical) ----------------------
# pass 1: dummy table, then genfunctab.py emits the real word offsets.
cmodel: xpkFRLE_lib.o functab.o xpkFRLE.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o xpkFRLE-c.library \
		xpkFRLE_lib.o functab.o xpkFRLE.o endmodule.o

dummy.library: xpkFRLE_lib.o functab_stub.o xpkFRLE.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o $@ \
		xpkFRLE_lib.o functab_stub.o xpkFRLE.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

xpkFRLE.o: xpkFRLE.c
	$(CC) $(CFLAGS) -c -o $@ xpkFRLE.c

clean:
	rm -f *.o *.nm functab.s dummy.library xpkFRLE-c.library $(TARGET)

.PHONY: all cmodel clean

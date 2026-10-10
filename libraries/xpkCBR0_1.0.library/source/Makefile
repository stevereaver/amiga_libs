# Makefile for xpkCBR0.library V1.0 C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# Same two-pass word-offset functab scheme as xpkFRLE/xpkRLEN.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = xpkCBR0.library

all: $(TARGET)

dummy.library: xpkCBR0_lib.o functab_stub.o xpkCBR0.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpkCBR0_lib.o functab_stub.o xpkCBR0.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

$(TARGET): xpkCBR0_lib.o functab.o xpkCBR0.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpkCBR0_lib.o functab.o xpkCBR0.o endmodule.o

xpkCBR0_lib.o: xpkCBR0_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkCBR0_lib.s

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

xpkCBR0.o: xpkCBR0.c
	$(CC) $(CFLAGS) -c -o $@ xpkCBR0.c

clean:
	rm -f *.o *.nm functab.s dummy.library $(TARGET)

.PHONY: all clean

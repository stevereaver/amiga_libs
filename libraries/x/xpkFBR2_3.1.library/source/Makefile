# Makefile for xpkFBR2.library 3.1 C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# Same two-pass word-offset functab scheme as the other XPK sublibs.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = xpkFBR2.library

all: $(TARGET)

dummy.library: xpkFBR2_lib.o functab_stub.o xpkFBR2.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpkFBR2_lib.o functab_stub.o xpkFBR2.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

$(TARGET): xpkFBR2_lib.o functab.o xpkFBR2.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpkFBR2_lib.o functab.o xpkFBR2.o endmodule.o

xpkFBR2_lib.o: xpkFBR2_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkFBR2_lib.s

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

xpkFBR2.o: xpkFBR2.c
	$(CC) $(CFLAGS) -c -o $@ xpkFBR2.c

clean:
	rm -f *.o *.nm functab.s dummy.library $(TARGET)

.PHONY: all clean

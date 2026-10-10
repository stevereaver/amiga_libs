# Makefile for xpkILZR.library 1.5 C reconstruction
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

TARGET  = xpkILZR.library

all: $(TARGET)

dummy.library: xpkILZR_lib.o functab_stub.o xpkILZR.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpkILZR_lib.o functab_stub.o xpkILZR.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

$(TARGET): xpkILZR_lib.o functab.o xpkILZR.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpkILZR_lib.o functab.o xpkILZR.o endmodule.o

xpkILZR_lib.o: xpkILZR_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkILZR_lib.s

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

xpkILZR.o: xpkILZR.c
	$(CC) $(CFLAGS) -c -o $@ xpkILZR.c

clean:
	rm -f *.o *.nm functab.s dummy.library $(TARGET)

.PHONY: all clean

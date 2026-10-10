# Makefile for xpkDMCB.library 1.1 C reconstruction
#
# The codec needs real 68881 extended-precision arithmetic, so the C
# part builds for 68020+68881 (long double == fp registers).
# Same two-pass word-offset functab scheme as the other XPK sublibs.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -m68881 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = xpkDMCB.library

all: $(TARGET)

dummy.library: xpkDMCB_lib.o functab_stub.o xpkDMCB.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpkDMCB_lib.o functab_stub.o xpkDMCB.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

$(TARGET): xpkDMCB_lib.o functab.o xpkDMCB.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpkDMCB_lib.o functab.o xpkDMCB.o endmodule.o

xpkDMCB_lib.o: xpkDMCB_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkDMCB_lib.s

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

xpkDMCB.o: xpkDMCB.c
	$(CC) $(CFLAGS) -c -o $@ xpkDMCB.c

clean:
	rm -f *.o *.nm functab.s dummy.library $(TARGET)

.PHONY: all clean

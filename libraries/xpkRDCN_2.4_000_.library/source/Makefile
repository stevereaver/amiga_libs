# Makefile for xpkRDCN.library 2.4 C reconstruction
#
# Two-pass word-offset functab: link a dummy image with a
# size-correct functab_stub.o, measure the final .text addresses,
# then generate functab.s with the real offsets.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = xpkRDCN.library

all: $(TARGET)

dummy.library: xpkRDCN_lib.o functab_stub.o xpkRDCN.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpkRDCN_lib.o functab_stub.o xpkRDCN.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

xpkRDCN_lib.o: xpkRDCN_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkRDCN_lib.s

xpkRDCN.o: xpkRDCN.c
	$(CC) $(CFLAGS) -c -o $@ xpkRDCN.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

$(TARGET): xpkRDCN_lib.o functab.o xpkRDCN.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpkRDCN_lib.o functab.o xpkRDCN.o endmodule.o

clean:
	rm -f *.o *.nm *.library dummy.library functab.s

.PHONY: all clean

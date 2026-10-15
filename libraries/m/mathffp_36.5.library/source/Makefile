# Makefile for mathffp.library 36.5 C reconstruction
# Commodore C= FFP math lib -- word-offset functab, packed RomTag.
#
# Two-pass word-offset functab: link a dummy image with a
# size-correct functab_stub.o, measure the final .text addresses,
# then generate functab.s with the real offsets.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm
TARGET  = mathffp.library

all: $(TARGET)

dummy.library: mathffp_lib.o functab_stub.o mathffp.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ mathffp_lib.o functab_stub.o mathffp.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab_stub.o: functab_stub.s
	$(CC) -m68000 -c -o $@ $<

functab.o: functab.s
	$(CC) -m68000 -c -o $@ $<

mathffp_lib.o: mathffp_lib.s
	$(CC) -m68000 -c -o $@ $<

mathffp.o: mathffp.c
	$(CC) $(CFLAGS) -c -o $@ $<

endmodule.o: endmodule.s
	$(CC) -m68000 -c -o $@ $<

$(TARGET): mathffp_lib.o functab.o mathffp.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ mathffp_lib.o functab.o mathffp.o endmodule.o

clean:
	rm -f *.o *.nm *.library dummy.library functab.s

.PHONY: all clean

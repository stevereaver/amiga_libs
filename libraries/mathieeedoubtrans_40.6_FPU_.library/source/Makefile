# Makefile for mathieeedoubtrans.library 40.6 (68881/82) reconstruction.
#
# `make`        -> byte-identical rebuild from mdt406_v.s (verbatim asm).
# `make cmodel` -> earlier C model (kept for reference, NOT identical).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
CASFLAGS = -m68020 -m68881
LDFLAGS = -nostdlib -nostartfiles

TARGET  = mathieeedoubtrans.library

all: $(TARGET)

$(TARGET): mdt406_v.o
	$(CC) $(LDFLAGS) -Wl,-s -o $@ mdt406_v.o

mdt406_v.o: mdt406_v.s
	$(CC) $(ASFLAGS) -c -o $@ mdt406_v.s

cmodel: mathieeedoubtrans_lib.o datatab.o mathieeedoubtrans.o math.o endmodule.o
	$(CC) $(LDFLAGS) -o mathieeedoubtrans_c.library mathieeedoubtrans_lib.o datatab.o mathieeedoubtrans.o math.o endmodule.o

mathieeedoubtrans_lib.o: mathieeedoubtrans_lib.s
	$(CC) $(CASFLAGS) -c -o $@ $<

datatab.o: datatab.s
	$(CC) $(CASFLAGS) -c -o $@ $<

math.o: math.s
	$(CC) $(CASFLAGS) -c -o $@ $<

endmodule.o: endmodule.s
	$(CC) $(CASFLAGS) -c -o $@ $<

mathieeedoubtrans.o: mathieeedoubtrans.c mdtbase.h
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all cmodel clean

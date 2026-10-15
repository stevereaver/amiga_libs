# Makefile for mathieeedoubbas.library 40.6 (68881/82) reconstruction.
#
# `make`        -> byte-identical rebuild from mdb406_v.s (verbatim asm).
# `make cmodel` -> earlier C model (kept for reference, NOT identical).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles

TARGET  = mathieeedoubbas.library

all: $(TARGET)

$(TARGET): mdb406_v.o
	$(CC) $(LDFLAGS) -Wl,-s -o $@ mdb406_v.o

mdb406_v.o: mdb406_v.s
	$(CC) $(ASFLAGS) -c -o $@ mdb406_v.s

cmodel: mathieeedoubbas_lib.o datatab.o mathieeedoubbas.o math.o endmodule.o
	$(CC) $(LDFLAGS) -o mathieeedoubbas_c.library mathieeedoubbas_lib.o datatab.o mathieeedoubbas.o math.o endmodule.o

mathieeedoubbas_lib.o: mathieeedoubbas_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

datatab.o: datatab.s
	$(CC) $(ASFLAGS) -c -o $@ $<

math.o: math.s
	$(CC) $(ASFLAGS) -c -o $@ $<

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ $<

mathieeedoubbas.o: mathieeedoubbas.c mdbbase.h
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all cmodel clean

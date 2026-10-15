# Makefile for mathtrans.library 40.6 (68881/82) reconstruction.
#
# `make`        -> byte-identical rebuild from mt406_v.s (verbatim asm).
# `make cmodel` -> earlier C model (kept for reference, NOT identical).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles

TARGET  = mathtrans.library

all: $(TARGET)

$(TARGET): mt406_v.o
	$(CC) $(LDFLAGS) -Wl,-s -o $@ mt406_v.o

mt406_v.o: mt406_v.s
	$(CC) $(ASFLAGS) -c -o $@ mt406_v.s

cmodel: mathtrans_lib.o datatab.o mathtrans.o math.o endmodule.o
	$(CC) $(LDFLAGS) -o mathtrans_c.library mathtrans_lib.o datatab.o mathtrans.o math.o endmodule.o

mathtrans_lib.o: mathtrans_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

datatab.o: datatab.s
	$(CC) $(ASFLAGS) -c -o $@ $<

math.o: math.s
	$(CC) $(ASFLAGS) -c -o $@ $<

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ $<

mathtrans.o: mathtrans.c mtbase.h
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all cmodel clean

# Makefile for fwfiltertype.library 3.0 reconstruction.
#
# `make`        -> byte-identical rebuild from fwfiltertype.s + fixup.py
# `make cmodel` -> earlier C model (functionally equivalent, not
#                  byte-identical; kept as semantic documentation)
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = fwfiltertype.library

all: $(TARGET)

$(TARGET): fwfiltertype-asm.o fixup.py
	$(CC) $(LDFLAGS) -Wl,-s -o $(TARGET) fwfiltertype-asm.o
	python3 fixup.py $(TARGET)

fwfiltertype-asm.o: fwfiltertype.s
	$(CC) $(ASFLAGS) -c -o $@ fwfiltertype.s

# --- earlier C model ---
cmodel: fwfiltertype_lib.o fwfiltertype.o endmodule.o
	$(CC) $(LDFLAGS) -o fwfiltertype-c.library fwfiltertype_lib.o \
		fwfiltertype.o endmodule.o

fwfiltertype_lib.o: fwfiltertype_lib.s
	$(CC) $(ASFLAGS) -c -o $@ fwfiltertype_lib.s

fwfiltertype.o: fwfiltertype.c
	$(CC) $(CFLAGS) -c -o $@ fwfiltertype.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o fwfiltertype-c.library $(TARGET)

.PHONY: all cmodel clean

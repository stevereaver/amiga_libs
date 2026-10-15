# Makefile for fantasia.library 1.0 reconstruction.
#
# `make`        -> byte-identical rebuild from fantasia_v.s
# `make cmodel` -> earlier C-model build (semantically equivalent,
#                  not byte-identical; kept as readable documentation)

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter -Wno-array-bounds
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = fantasia.library
ORIG    = '../binary/fantasia_1.0.library'

all: $(TARGET)

$(TARGET): fantasia_v.o
	$(CC) $(LDFLAGS) -o $(TARGET) fantasia_v.o

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

# --- earlier C model ---
cmodel: fantasia_lib.o functab.o datatab.o fantasia.o fantasia_hw.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o fantasia-c.library fantasia_lib.o functab.o datatab.o fantasia.o fantasia_hw.o endmodule.o

clean:
	rm -f *.o $(TARGET) fantasia-c.library dummy.library dummy.nm

.PHONY: all cmodel clean

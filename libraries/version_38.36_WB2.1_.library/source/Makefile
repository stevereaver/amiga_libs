# Makefile for version.library 38.36 (WB2.1) reconstruction.
#
# `make`        -> byte-identical rebuild from version.s + fixup.py
# `make cmodel` -> earlier C-model build (functionally equivalent,
#                  not byte-identical; kept as semantic documentation)
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = version.library

all: $(TARGET)

$(TARGET): version.o fixup.py
	$(CC) $(LDFLAGS) -Wl,-s -o $(TARGET) version.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

# --- earlier C model ---
cmodel: version_lib.o version_c.o endmodule.o
	$(CC) $(LDFLAGS) -o version-c.library version_lib.o version_c.o endmodule.o

version_c.o: version.c
	$(CC) $(CFLAGS) -c -o $@ version.c

clean:
	rm -f *.o version-c.library $(TARGET)

.PHONY: all cmodel clean

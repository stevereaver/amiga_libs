# Makefile for the Phase5 dummy 68040.library 44.1 loader stub
#
# Default target builds the byte-identical verbatim assembly
# reconstruction (dummy_v.s + fixup.py rewrites the reloc tail).
# `make cmodel` builds the older readable C model (NOT byte-identical).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68040
LDFLAGS = -nostdlib -nostartfiles

ORIG    = ../binary/68040dummy_44.1.library
TARGET  = 68040.library

all: $(TARGET)

$(TARGET): dummy_v.o
	$(CC) $(LDFLAGS) -Wl,-s -o dummy_v.library dummy_v.o
	python3 fixup.py dummy_v.library $(ORIG)
	cp dummy_v.library $(TARGET)

dummy_v.o: dummy_v.s
	$(CC) -m68000 -c -o $@ dummy_v.s

cmodel:
	$(CC) $(ASFLAGS) -c -o dummy_lib.o dummy_lib.s
	$(CC) $(CFLAGS)  -c -o dummy.o dummy.c
	$(CC) $(ASFLAGS) -c -o helpers.o helpers.s
	$(CC) $(ASFLAGS) -c -o endmodule.o endmodule.s
	$(CC) $(LDFLAGS) -o 68040_cmodel.library dummy_lib.o dummy.o helpers.o endmodule.o

clean:
	rm -f *.o $(TARGET) dummy_v.library 68040_cmodel.library

.PHONY: all clean cmodel

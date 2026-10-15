# Makefile for the Phase5 68040.library 46.5 loader stub
#
# Default target builds the byte-identical verbatim assembly
# reconstruction (68040_v.s + fixup.py rewrites the reloc tail).
# `make cmodel` builds the older readable C model (NOT byte-identical).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68040
LDFLAGS = -nostdlib -nostartfiles

ORIG    = ../binary/68040_46.5.library
TARGET  = 68040.library

all: $(TARGET)

$(TARGET): 68040_v.o
	$(CC) $(LDFLAGS) -Wl,-s -o 68040_v.library 68040_v.o
	python3 fixup.py 68040_v.library $(ORIG)
	cp 68040_v.library $(TARGET)

68040_v.o: 68040_v.s
	$(CC) -m68000 -Wa,-m68020 -c -o $@ 68040_v.s

cmodel:
	$(CC) $(ASFLAGS) -c -o loader_lib.o loader_lib.s
	$(CC) $(CFLAGS)  -c -o loader.o loader.c
	$(CC) $(ASFLAGS) -c -o helpers.o helpers.s
	$(CC) $(ASFLAGS) -c -o endmodule.o endmodule.s
	$(CC) $(LDFLAGS) -o 68040_cmodel.library loader_lib.o loader.o helpers.o endmodule.o

clean:
	rm -f *.o $(TARGET) 68040_v.library 68040_cmodel.library

.PHONY: all clean cmodel

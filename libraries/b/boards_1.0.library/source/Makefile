# Makefile for boards.library 1.0 reconstruction.
# `make`        -> byte-identical rebuild from boards.s (fixup.py
#                  rewrites GNU ld's RELOC32 tail into the original's
#                  DREL16 0x3f7 records with the original ordering)
# `make cmodel` -> earlier C model (documentation, not byte-identical)
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = boards.library
ORIG    = ../binary/boards_1.0.library

all: $(TARGET)

$(TARGET): boards_h0.o fixup.py
	$(CC) $(LDFLAGS) -o $(TARGET) boards_h0.o
	python3 fixup.py $(TARGET) $(ORIG)

boards_h0.o: boards.s
	$(CC) $(ASFLAGS) -c -o $@ boards.s

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

cmodel: boards_lib.o boards_c.o boards_func.o datatab.o endmodule.o
	$(CC) $(LDFLAGS) -o boards-c.library boards_lib.o boards_c.o boards_func.o datatab.o endmodule.o

boards_c.o: boards.c
	$(CC) $(CFLAGS) -c -o $@ boards.c

clean:
	rm -f *.o boards-c.library $(TARGET)

.PHONY: all cmodel clean

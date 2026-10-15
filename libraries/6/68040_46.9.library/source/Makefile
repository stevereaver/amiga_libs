# Makefile for 68040.library 46.9 (040/060-Loader) reconstruction.
# `make`        -> byte-identical rebuild from 68040.s
# `make cmodel` -> earlier C model (documentation, not byte-identical)
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = 68040.library

all: $(TARGET)

$(TARGET): 68040.o
	$(CC) $(LDFLAGS) -Wl,-s -o $(TARGET) 68040.o

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

cmodel: loader_lib.o loader.o endmodule.o
	$(CC) $(LDFLAGS) -o 68040-c.library loader_lib.o loader.o endmodule.o

loader.o: loader.c
	$(CC) $(CFLAGS) -c -o $@ loader.c

clean:
	rm -f *.o 68040-c.library $(TARGET)

.PHONY: all cmodel clean

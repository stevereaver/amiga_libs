# Makefile for f1gp.library 35.4 reconstruction -- pure asm, byte-identical

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = f1gp.library

all: $(TARGET)

f1gp_lib.o: f1gp_lib.s
	$(CC) $(ASFLAGS) -c -o $@ f1gp_lib.s

$(TARGET): f1gp_lib.o fixup.py
	$(CC) $(LDFLAGS) -o $@ f1gp_lib.o
	python3 fixup.py $(TARGET)

clean:
	rm -f *.o *.library

.PHONY: all clean

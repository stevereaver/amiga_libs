# Makefile for screennotify.library 1.0 reconstruction -- pure asm, byte-identical

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = screennotify.library

all: $(TARGET)

screennotify.o: screennotify.s
	$(CC) $(ASFLAGS) -c -o $@ screennotify.s

$(TARGET): screennotify.o fixup.py
	$(CC) $(LDFLAGS) -o $@ screennotify.o
	python3 fixup.py $(TARGET)

clean:
	rm -f *.o *.library

.PHONY: all clean

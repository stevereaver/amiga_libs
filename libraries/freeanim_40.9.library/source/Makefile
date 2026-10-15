# Makefile for freeanim.library 40.9 reconstruction.
CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = freeanim.library

all: $(TARGET)

$(TARGET): freeanim.o
	$(CC) $(LDFLAGS) -o $(TARGET) freeanim.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

verify: $(TARGET)
	cmp -l $(TARGET) ../binary/freeanim_40.9.library && echo IDENTICAL || echo DIFFERS

clean:
	rm -f *.o $(TARGET)

.PHONY: all verify clean

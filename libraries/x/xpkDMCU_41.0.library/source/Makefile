# Makefile for xpkDMCU.library 41.0 reconstruction.
CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = xpkDMCU.library

all: $(TARGET)

$(TARGET): xpkDMCU_h0.o xpkDMCU_h1.o
	$(CC) $(LDFLAGS) -o $(TARGET) xpkDMCU_h0.o xpkDMCU_h1.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

verify: $(TARGET)
	cmp -l $(TARGET) ../binary/xpkDMCU_41.0.library && echo IDENTICAL || echo DIFFERS

clean:
	rm -f *.o $(TARGET)

.PHONY: all verify clean

# Makefile for version.library reconstruction (WB-version stubs).
CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

ORIG    := $(wildcard ../binary/*)
TARGET  = version.library

all: $(TARGET)

$(TARGET): version.o
	$(CC) $(LDFLAGS) -o $(TARGET) version.o

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

verify: $(TARGET)
	cmp -l $(TARGET) $(ORIG) && echo IDENTICAL || echo DIFFERS

clean:
	rm -f *.o $(TARGET)

.PHONY: all verify clean

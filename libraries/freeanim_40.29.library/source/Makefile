# Makefile for freeanim.library 40.29 reconstruction (stub lib).
CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = freeanim.library

all: $(TARGET)

$(TARGET): freeanim.o
	$(CC) $(LDFLAGS) -o $(TARGET) freeanim.o

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

verify: $(TARGET)
	cmp -l $(TARGET) ../binary/freeanim_40.29.library && echo IDENTICAL || echo DIFFERS

clean:
	rm -f *.o $(TARGET)

.PHONY: all verify clean

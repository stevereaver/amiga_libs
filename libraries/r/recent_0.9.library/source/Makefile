# Makefile for recent.library 0.9 reconstruction.
# Single CODE hunk (2848B): RomTag + InitTable + 13-vector functab +
# InitStruct datatab + all code + ENVARC:Recent/ + RCNT data tail.
# fixup.py restores the original single RELOC32 group order.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = recent.library
OBJS    = recent_h0.o

all: $(TARGET)

$(TARGET): $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJS)
	python3 fixup.py $(TARGET)

clean:
	rm -f $(TARGET) $(OBJS)

.PHONY: all clean

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

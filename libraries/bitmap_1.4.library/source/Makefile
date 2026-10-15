# Makefile for bitmap.library 1.4
# Default target: byte-verbatim hand-asm reconstruction of the shipped
# CODE+DATA binary; fixup.py verifies hunk bodies and splices the
# original RELOC32 trailers, then cmp proves identity.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = bitmap.library

all: $(TARGET) verify

$(TARGET): bitmap_h0.o
	$(CC) $(LDFLAGS) -o $@ $<
	python3 fixup.py $@

bitmap_h0.o: bitmap_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

verify:
	@cmp -s $(TARGET) ../binary/bitmap_1.4.library \
	  && echo BYTE-IDENTICAL || echo "DIFFERS (see work/)"

clean:
	rm -f *.o $(TARGET)

.PHONY: all verify clean

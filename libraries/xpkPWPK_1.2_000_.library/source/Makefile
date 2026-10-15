# Makefile for xpkPWPK.library 1.2(000)
# Default target: byte-verbatim hand-asm reconstruction of the shipped
# single-CODE-hunk binary; fixup.py verifies the hunk body and splices
# the original RELOC32 trailer, then cmp proves identity.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = xpkPWPK.library

all: $(TARGET) verify

$(TARGET): xpkPWPK_h0.o
	$(CC) $(LDFLAGS) -o $@ $<
	python3 fixup.py $@

xpkPWPK_h0.o: xpkPWPK_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

verify:
	@cmp -s $(TARGET) "../binary/xpkPWPK_1.2(000).library" \
	  && echo BYTE-IDENTICAL || echo "DIFFERS (see work/)"

clean:
	rm -f *.o $(TARGET)

.PHONY: all verify clean

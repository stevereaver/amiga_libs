# Makefile for xpkNUKE.library V1.1
#
# Byte-verbatim assembly reconstruction (xpkNUKE_h0.s = CODE hunk,
# xpkNUKE_h1.s = DATA hunk).  The verbatim sources use only literal
# operands, so gas emits no RELOC32 records; fixup.py splices the
# original tails (16+2 RELOC32 offsets for h0, 2 for h1) after checking
# the hunk bodies match.  `make` verifies with cmp.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = xpkNUKE.library

all: $(TARGET) verify

$(TARGET): xpkNUKE_h0.o xpkNUKE_h1.o
	$(CC) $(LDFLAGS) -o $@ xpkNUKE_h0.o xpkNUKE_h1.o
	python3 fixup.py $@

xpkNUKE_h0.o: xpkNUKE_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

xpkNUKE_h1.o: xpkNUKE_h1.s
	$(CC) $(ASFLAGS) -c -o $@ $<

verify:
	@cmp -s $(TARGET) ../binary/xpkNUKE_1.1.library && echo BYTE-IDENTICAL \
	  || echo "DIFFERS (see work/)"

clean:
	rm -f *.o $(TARGET)

.PHONY: all verify clean

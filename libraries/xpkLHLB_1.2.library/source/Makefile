# Makefile for xpkLHLB.library V1.2
#
# Byte-verbatim assembly reconstruction (xpkLHLB_h0.s).  The verbatim
# source uses only literal operands, so gas emits no RELOC32 records;
# fixup.py splices the original 14-entry RELOC32 tail (stored in
# descending order) after checking the hunk body matches.  `make`
# verifies with cmp.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = xpkLHLB.library

all: $(TARGET) verify

$(TARGET): xpkLHLB_h0.o
	$(CC) $(LDFLAGS) -o $@ $<
	python3 fixup.py $@

xpkLHLB_h0.o: xpkLHLB_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

verify:
	@cmp -s $(TARGET) ../binary/xpkLHLB_1.2.library && echo BYTE-IDENTICAL \
	  || echo "DIFFERS (see work/)"

clean:
	rm -f *.o $(TARGET)

.PHONY: all verify clean

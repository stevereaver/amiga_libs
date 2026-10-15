# Makefile for iff.library 22.3 (Christian A. Weber)
#
# Byte-verbatim assembly reconstruction (iff_h0.s).  The verbatim
# source uses only literal operands, so gas emits no RELOC32 records;
# fixup.py splices the original 10-entry RELOC32 tail after checking
# the hunk body matches.  The file has a second 4-byte zero DATA hunk
# (the .data section below).  `make` verifies with cmp.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = iff.library

all: $(TARGET) verify

$(TARGET): iff_h0.o
	$(CC) $(LDFLAGS) -o $@ $<
	python3 fixup.py $@

iff_h0.o: iff_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

verify:
	@cmp -s $(TARGET) ../binary/iff_22.3.library && echo BYTE-IDENTICAL \
	  || echo "DIFFERS (see work/)"

clean:
	rm -f $(TARGET) *.o

.PHONY: all verify clean

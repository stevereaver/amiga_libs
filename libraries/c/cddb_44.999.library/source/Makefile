# Makefile for cddb.library 44.999 reconstruction.
# Two hunks: h0 CODE (all code + strings + functab), h1 DATA
# (InitTable + runtime template). fixup.py restores the original
# RELOC32 grouping/order.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = cddb.library

all: $(TARGET)

$(TARGET): cddb_h0.o cddb_h1.o fixup.py
	printf 'SECTIONS { .h0 : { cddb_h0.o(.text) } .data : { cddb_h1.o(.data) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) cddb_h0.o cddb_h1.o
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

verify: $(TARGET)
	cmp -l $(TARGET) ../binary/cddb_44.999.library && echo IDENTICAL || echo DIFFERS
	md5sum $(TARGET) ../binary/cddb_44.999.library

clean:
	rm -f *.o $(TARGET)

.PHONY: all verify clean

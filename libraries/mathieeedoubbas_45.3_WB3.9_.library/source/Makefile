# Makefile for mathieeedoubbas.library 45.3 (WB3.9) reconstruction.
# Single CODE hunk; the verbatim .s image is linked and the original
# header + RELOC32 tail is spliced back by fixup.py.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = mathieeedoubbas.library
ORIG    = ../binary/mathieeedoubbas_45.3(WB3.9).library

all: $(TARGET)

$(TARGET): mathieeedoubbas_45.3_h0.o fixup.py
	$(CC) $(LDFLAGS) -o $@ mathieeedoubbas_45.3_h0.o
	python3 fixup.py $@
	cmp $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

# Makefile for xpkRLEN.library 1.3
# Default: byte-verbatim assembly reconstruction (xpkRLEN_h0.s),
# then fixup.py rewrites the RELOC32 groups to the shipped binary's
# scrambled order (ascending sub-runs, each reversed, back-to-front).
# `make cmodel` builds the earlier C reconstruction.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = xpkRLEN.library

all: $(TARGET) verify

$(TARGET): xpkRLEN_h0.o
	$(CC) $(LDFLAGS) -o $@ $<
	python3 fixup.py $@ ../binary/xpkRLEN_1.3.library

xpkRLEN_h0.o: xpkRLEN_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

cmodel: xpkRLEN_lib.o xpkRLEN.o
	$(CC) -nostdlib -nostartfiles -o $(TARGET) $^

xpkRLEN_lib.o: xpkRLEN_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

xpkRLEN.o: xpkRLEN.c
	$(CC) $(CFLAGS) -c -o $@ $<

verify:
	@cmp -s $(TARGET) ../binary/xpkRLEN_1.3.library && echo BYTE-IDENTICAL \
	  || echo "DIFFERS (see work/)"

clean:
	rm -f *.o $(TARGET)

.PHONY: all cmodel verify clean

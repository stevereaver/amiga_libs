# Makefile for xpkDLTA.library V1.5 (000) C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
#
# The AUTOINIT function table is a list of word offsets relative to
# the table start.  gas cannot express "extern_sym - local_sym" in
# a .word across objects, so the table is generated in a second link
# pass: a dummy table of the right size is linked, symbol addresses
# are read with nm, and genfunctab.py emits the real .word values.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = xpkDLTA.library

all: $(TARGET)

# pass 1: dummy table (same size as the real one), just to learn the
# final addresses of every function in the code hunk.
dummy.library: xpkDLTA_lib.o functab_stub.o xpkDLTA.o
	$(CC) $(LDFLAGS) -o $@ xpkDLTA_lib.o functab_stub.o xpkDLTA.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

$(TARGET): xpkDLTA_lib.o functab.o xpkDLTA.o
	$(CC) $(LDFLAGS) -o $@ xpkDLTA_lib.o functab.o xpkDLTA.o

xpkDLTA_lib.o: xpkDLTA_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkDLTA_lib.s

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

xpkDLTA.o: xpkDLTA.c
	$(CC) $(CFLAGS) -c -o $@ xpkDLTA.c

clean:
	rm -f *.o *.nm functab.s dummy.library $(TARGET)

.PHONY: all clean

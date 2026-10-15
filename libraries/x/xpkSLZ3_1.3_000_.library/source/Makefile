# Makefile for xpkSLZ3.library 1.3 (000) C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# The AUTOINIT functab is the word-offset format: pass 1 links a
# placeholder table so genfunctab.py can emit offsets relative to
# the -1 marker, pass 2 links the real table.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkSLZ3.library

all: $(TARGET)

# pass 1: dummy link to resolve symbol addresses
dummy.library: xpkSLZ3_lib.o functab_stub.o xpkSLZ3.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpkSLZ3_lib.o functab_stub.o xpkSLZ3.o endmodule.o

functab.s: dummy.library genfunctab.py
	/opt/amiga/bin/m68k-amigaos-nm dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

# pass 2: final link with the real functab
$(TARGET): xpkSLZ3_lib.o functab.o xpkSLZ3.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpkSLZ3_lib.o functab.o xpkSLZ3.o endmodule.o

xpkSLZ3_lib.o: xpkSLZ3_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ $<

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ $<

xpkSLZ3.o: xpkSLZ3.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.nm functab.s dummy.library $(TARGET)

.PHONY: all clean

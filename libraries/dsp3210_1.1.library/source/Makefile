# Makefile for dsp3210.library 1.1 (3.1.2020) C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# Non-AUTOINIT module: MakeLibrary is driven by _ResidentInit, so no
# InitTable/InitStruct is emitted.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = dsp3210.library

all: $(TARGET)

$(TARGET): dsp3210_lib.o dsp3210.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ dsp3210_lib.o dsp3210.o endmodule.o

dsp3210_lib.o: dsp3210_lib.s
	$(CC) $(ASFLAGS) -c -o $@ dsp3210_lib.s

dsp3210.o: dsp3210.c dspbase.h
	$(CC) $(CFLAGS) -c -o $@ dsp3210.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

# Makefile for xpkDLTA.library V0.1
#
# Default target: byte-verbatim assembly reconstruction (xpkDLTA_h0.s).
# `make cmodel` builds the earlier C reconstruction for reference.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = xpkDLTA.library

all: $(TARGET) verify

$(TARGET): xpkDLTA_h0.o
	$(CC) $(LDFLAGS) -o $@ $<

xpkDLTA_h0.o: xpkDLTA_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

cmodel: xpkDLTA_lib.o xpkDLTA.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o $(TARGET) $^

xpkDLTA_lib.o: xpkDLTA_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ $<

xpkDLTA.o: xpkDLTA.c
	$(CC) $(CFLAGS) -c -o $@ $<

verify:
	@cmp -s $(TARGET) ../binary/xpkDLTA_0.1.library && echo BYTE-IDENTICAL \
	  || echo "DIFFERS (see work/)"

clean:
	rm -f *.o $(TARGET)

.PHONY: all cmodel verify clean

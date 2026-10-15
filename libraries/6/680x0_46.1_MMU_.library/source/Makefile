# Makefile for 680x0.library 40.4 (MMU.lib)
#
# Default: byte-verbatim assembly reconstruction (680x0_h0.s) --
# `make` builds and verifies against ../binary.  `make cmodel`
# builds the earlier C reconstruction (680x0.c + cpuprobe.s +
# 680x0_lib.s).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = 680x0.library

all: $(TARGET) verify

$(TARGET): 680x0_h0.o
	$(CC) $(LDFLAGS) -o $@ $<

680x0_h0.o: 680x0_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

# --- reference C model (not byte-identical) ----------------------
cmodel: 680x0_lib.o cpuprobe.o 680x0.o
	$(CC) -nostdlib -nostartfiles -o $(TARGET)-c \
		680x0_lib.o cpuprobe.o 680x0.o

680x0_lib.o: 680x0_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

cpuprobe.o: cpuprobe.s
	$(CC) $(ASFLAGS) -c -o $@ $<

680x0.o: 680x0.c
	$(CC) $(CFLAGS) -c -o $@ $<

verify:
	@cmp -s $(TARGET) '../binary/680x0_46.1(MMU).library' && echo BYTE-IDENTICAL \
	  || echo "DIFFERS (see work/)"

clean:
	rm -f *.o *.nm $(TARGET) $(TARGET)-c

.PHONY: all cmodel verify clean

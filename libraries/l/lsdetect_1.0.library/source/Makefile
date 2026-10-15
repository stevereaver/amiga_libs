CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

# Default: byte-verbatim asm reconstruction (lsdetect_h0.s) +
# fixup.py (17-entry RELOC32 splice).  `make` verifies with cmp.

lsdetect.library: lsdetect_h0.o
	$(CC) $(LDFLAGS) -Wl,-s -o $@ lsdetect_h0.o
	python3 fixup.py $@
	cmp $@ ../binary/lsdetect_1.0.library && echo BYTE-IDENTICAL

# Semantic C model preserved for reference.
cmodel: lsdetect_lib.o lsdetect.o endmodule.o
	$(CC) $(LDFLAGS) -o lsdetect_c.library lsdetect_lib.o lsdetect.o endmodule.o

lsdetect_h0.o: lsdetect_h0.s
	$(CC) $(ASFLAGS) -c -o $@ lsdetect_h0.s

lsdetect_lib.o: lsdetect_lib.s
	$(CC) $(ASFLAGS) -c -o $@ lsdetect_lib.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

lsdetect.o: lsdetect.c
	$(CC) $(CFLAGS) -c -o $@ lsdetect.c

clean:
	rm -f *.o *.library

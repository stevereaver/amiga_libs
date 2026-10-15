CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

# Default: byte-verbatim asm reconstruction (dsp3210_h0.s) +
# fixup.py (11-entry descending RELOC32 splice).  `make` cmp-verifies.

dsp3210.library: dsp3210_h0.o
	$(CC) $(LDFLAGS) -Wl,-s -o $@ dsp3210_h0.o
	python3 fixup.py $@
	cmp $@ ../binary/dsp3210_1.1.library && echo BYTE-IDENTICAL

# Semantic C model preserved for reference.
cmodel: dsp3210_lib.o dsp3210.o endmodule.o
	$(CC) $(LDFLAGS) -o dsp3210_c.library dsp3210_lib.o dsp3210.o endmodule.o

dsp3210_h0.o: dsp3210_h0.s
	$(CC) $(ASFLAGS) -c -o $@ dsp3210_h0.s

dsp3210_lib.o: dsp3210_lib.s dspbase.h
	$(CC) $(ASFLAGS) -c -o $@ dsp3210_lib.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

dsp3210.o: dsp3210.c dspbase.h
	$(CC) $(CFLAGS) -c -o $@ dsp3210.c

clean:
	rm -f *.o *.library

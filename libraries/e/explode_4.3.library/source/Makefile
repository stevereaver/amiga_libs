CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

# Default: byte-verbatim asm reconstruction (explode_h0.s).  The
# source uses only literal operands so gas emits no RELOC32 records;
# fixup.py splices the original 16-entry RELOC32 tail after checking
# the hunk body matches.  `make` verifies with cmp.

explode.library: explode_h0.o
	$(CC) $(LDFLAGS) -Wl,-s -o $@ explode_h0.o
	python3 fixup.py $@
	cmp $@ ../binary/explode_4.3.library && echo BYTE-IDENTICAL

# Semantic C model (earlier reconstruction) preserved for reference.
cmodel: explode_lib.o explode.o endmodule.o
	$(CC) $(LDFLAGS) -o explode_c.library explode_lib.o explode.o endmodule.o

explode_h0.o: explode_h0.s
	$(CC) $(ASFLAGS) -c -o $@ explode_h0.s

explode_lib.o: explode_lib.s explbase.h
	$(CC) $(ASFLAGS) -c -o $@ explode_lib.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

explode.o: explode.c explbase.h
	$(CC) $(CFLAGS) -c -o $@ explode.c

clean:
	rm -f *.o *.library

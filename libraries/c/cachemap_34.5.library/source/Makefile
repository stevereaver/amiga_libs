# Makefile for cachemap.library 34.5
#
# Default: byte-verbatim assembly reconstruction (cachemap_h0.s).
# GNU ld emits the single ascending RELOC32 group exactly like the
# shipped binary -- no fixup pass needed.  `make` verifies with cmp.
# `make cmodel` builds the earlier C reconstruction (two-pass
# genfunctab for the word-offset table).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = cachemap.library

all: $(TARGET) verify

$(TARGET): cachemap_h0.o
	$(CC) $(LDFLAGS) -o $@ $<

cachemap_h0.o: cachemap_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

verify:
	@cmp -s $(TARGET) ../binary/cachemap_34.5.library && echo BYTE-IDENTICAL \
	  || echo "DIFFERS (see work/)"

# ---- earlier C reconstruction (larger codegen, semantics only) --
cmodel: cachemap_lib.o functab.o cachemap.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o $(TARGET) \
	  cachemap_lib.o functab.o cachemap.o endmodule.o

dummy.library: cachemap_lib.o functab_stub.o cachemap.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o $@ \
	  cachemap_lib.o functab_stub.o cachemap.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

cachemap_lib.o: cachemap_lib.s
	$(CC) $(ASFLAGS) -c -o $@ cachemap_lib.s

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

cachemap.o: cachemap.c
	$(CC) $(CFLAGS) -c -o $@ cachemap.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o *.nm functab.s dummy.library $(TARGET)

.PHONY: all cmodel verify clean

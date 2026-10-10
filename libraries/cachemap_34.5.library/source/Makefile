# Makefile for cachemap.library 34.5 C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
#
# The AUTOINIT function table is a list of word offsets relative to
# the table start (marker -1W ... -1W).  gas cannot express
# "extern_sym - local_sym" in a .word across objects, so the table is
# generated in a second link pass (same scheme as iffparse).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = cachemap.library

all: $(TARGET)

dummy.library: cachemap_lib.o functab_stub.o cachemap.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ cachemap_lib.o functab_stub.o cachemap.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

$(TARGET): cachemap_lib.o functab.o cachemap.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ cachemap_lib.o functab.o cachemap.o endmodule.o

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

.PHONY: all clean

# Makefile for version.library 47.2 (Workbench 3.2) C reconstruction
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# Two-pass link to generate the AUTOINIT word-offset function table.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = version.library

all: $(TARGET)

dummy.library: version_lib.o functab_stub.o version.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ version_lib.o functab_stub.o version.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

$(TARGET): version_lib.o functab.o version.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ version_lib.o functab.o version.o endmodule.o

version_lib.o: version_lib.s
	$(CC) $(ASFLAGS) -c -o $@ version_lib.s

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

version.o: version.c versionbase.h
	$(CC) $(CFLAGS) -c -o $@ version.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o *.nm functab.s dummy.library $(TARGET)

.PHONY: all clean

# Makefile for version.library 47.2 reconstruction.
#
# `make`            -> byte-identical rebuild from version.s
# `make cmodel`     -> earlier C-model build (functionally equivalent,
#                      not byte-identical; kept as semantic documentation)
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = version.library

all: $(TARGET)

$(TARGET): version.o
	$(CC) $(LDFLAGS) -o $(TARGET) version.o

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

# --- earlier C model (two-pass functab generation) ---
cmodel: version_lib.o functab.o version_c.o endmodule.o
	$(CC) $(LDFLAGS) -o version-c.library version_lib.o functab.o version_c.o endmodule.o

version_c.o: version.c
	$(CC) $(CFLAGS) -c -o $@ version.c

dummy.library: version_lib.o functab_stub.o version_c.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ version_lib.o functab_stub.o version_c.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

version_lib.o: version_lib.s
	$(CC) $(ASFLAGS) -c -o $@ version_lib.s

clean:
	rm -f *.o $(TARGET) version-c.library dummy.library dummy.nm functab.s

.PHONY: all cmodel clean

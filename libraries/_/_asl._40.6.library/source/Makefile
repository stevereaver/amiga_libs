# Makefile for _asl.library 40.6 reconstruction.
#
# `make`        -> byte-identical rebuild from _asl.s
# `make cmodel` -> earlier multi-file model (functionally equivalent,
#                  not byte-identical; kept as semantic documentation)
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = _asl.library

all: $(TARGET)

$(TARGET): _asl.o
	$(CC) $(LDFLAGS) -Wl,-s -o $(TARGET) _asl.o

_asl.o: _asl.s
	$(CC) $(ASFLAGS) -c -o $@ _asl.s

# --- earlier C model ---
cmodel: asl_lib.o functab.o datatab.o asl.o asl_relay.o endmodule.o
	$(CC) $(LDFLAGS) -o _asl-c.library asl_lib.o functab.o datatab.o \
		asl.o asl_relay.o endmodule.o

dummy.library: asl_lib.o functab_stub.o datatab.o asl.o asl_relay.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ asl_lib.o functab_stub.o datatab.o \
		asl.o asl_relay.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

asl.o: asl.c
	$(CC) $(CFLAGS) -c -o $@ asl.c

clean:
	rm -f *.o *.nm functab.s dummy.library _asl-c.library $(TARGET)

.PHONY: all cmodel clean

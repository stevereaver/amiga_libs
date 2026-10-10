# Makefile for freeanim.library 40.9 C reconstruction
#
# Two-pass link: pass 1 uses a size-correct dummy function table so
# nm gives the final .text addresses; genfunctab.py then emits
# functab.s with word offsets relative to _functab, and pass 2 links
# the real table.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = freeanim.library

all: $(TARGET)

dummy.library: freeanim_lib.o functab_stub.o datatab.o freeanim.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ freeanim_lib.o functab_stub.o datatab.o freeanim.o endmodule.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

$(TARGET): freeanim_lib.o functab.o datatab.o freeanim.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ freeanim_lib.o functab.o datatab.o freeanim.o endmodule.o

freeanim_lib.o: freeanim_lib.s
	$(CC) $(ASFLAGS) -c -o $@ freeanim_lib.s

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

datatab.o: datatab.s
	$(CC) $(ASFLAGS) -c -o $@ datatab.s

freeanim.o: freeanim.c
	$(CC) $(CFLAGS) -c -o $@ freeanim.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o *.nm functab.s dummy.library $(TARGET)

.PHONY: all clean

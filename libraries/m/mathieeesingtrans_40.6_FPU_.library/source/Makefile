# Makefile for mathieeesingtrans.library 40.6 (68881/82) reconstruction.
#
# `make`        -> byte-identical rebuild from mst406_v.s (verbatim asm).
# `make cmodel` -> earlier C model (kept for reference, NOT identical).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles

TARGET  = mathieeesingtrans.library

all: $(TARGET)

$(TARGET): mst406_v.o
	$(CC) $(LDFLAGS) -Wl,-s -o $@ mst406_v.o

mst406_v.o: mst406_v.s
	$(CC) $(ASFLAGS) -c -o $@ mst406_v.s

cmodel: mathieeesingtrans_lib.o datatab.o mathieeesingtrans.o math.o endmodule.o
	$(CC) $(LDFLAGS) -o mathieeesingtrans_c.library mathieeesingtrans_lib.o datatab.o mathieeesingtrans.o math.o endmodule.o

mathieeesingtrans_lib.o: mathieeesingtrans_lib.s
	$(CC) $(ASFLAGS) -c -o $@ mathieeesingtrans_lib.s

datatab.o: datatab.s
	$(CC) $(ASFLAGS) -c -o $@ datatab.s

mathieeesingtrans.o: mathieeesingtrans.c mstbase.h
	$(CC) $(CFLAGS) -c -o $@ mathieeesingtrans.c

math.o: math.s
	$(CC) $(ASFLAGS) -c -o $@ math.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

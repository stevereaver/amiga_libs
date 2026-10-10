# Makefile for mathieeesingtrans.library 40.6 (68881/82) reconstruction.
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# The AUTOINIT function table uses absolute longwords, so a single
# link pass suffices -- no generated word-offset table.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles

TARGET  = mathieeesingtrans.library

all: $(TARGET)

$(TARGET): mathieeesingtrans_lib.o datatab.o mathieeesingtrans.o math.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ mathieeesingtrans_lib.o datatab.o mathieeesingtrans.o math.o endmodule.o

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

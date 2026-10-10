# Makefile for fantasia.library 1.0 C reconstruction
#
# Absolute-long AUTOINIT function table (functab.s) -- no two-pass
# link needed.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter -Wno-array-bounds
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = fantasia.library

all: $(TARGET)

$(TARGET): fantasia_lib.o functab.o datatab.o fantasia.o fantasia_hw.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ fantasia_lib.o functab.o datatab.o fantasia.o fantasia_hw.o endmodule.o

fantasia_lib.o: fantasia_lib.s
	$(CC) $(ASFLAGS) -c -o $@ fantasia_lib.s

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

datatab.o: datatab.s
	$(CC) $(ASFLAGS) -c -o $@ datatab.s

fantasia.o: fantasia.c
	$(CC) $(CFLAGS) -c -o $@ fantasia.c

fantasia_hw.o: fantasia_hw.s
	$(CC) $(ASFLAGS) -c -o $@ fantasia_hw.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

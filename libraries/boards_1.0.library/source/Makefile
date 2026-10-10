# Makefile for boards.library 1.0 C reconstruction
#
# This binary uses an ABSOLUTE-LONG AUTOINIT function table (unlike
# the word-offset scheme of iffparse/freeanim/_asl), so the table is
# a hand-written .long list in functab.s and no two-pass link is
# needed -- REL32 relocations do the work.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter -Wno-array-bounds
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = boards.library

all: $(TARGET)

$(TARGET): boards_lib.o functab.o datatab.o boards.o boards_func.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ boards_lib.o functab.o datatab.o boards.o boards_func.o endmodule.o

boards_lib.o: boards_lib.s
	$(CC) $(ASFLAGS) -c -o $@ boards_lib.s

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

datatab.o: datatab.s
	$(CC) $(ASFLAGS) -c -o $@ datatab.s

boards.o: boards.c
	$(CC) $(CFLAGS) -c -o $@ boards.c

boards_func.o: boards_func.s
	$(CC) $(ASFLAGS) -c -o $@ boards_func.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

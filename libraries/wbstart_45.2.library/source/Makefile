# Makefile for wbstart.library 45.2 C reconstruction
#
# Two-hunk module: .text (entry stubs + code + string literals) and
# .data (absolute-longword function table, name/id strings,
# InitTable, RomTag, EndSkip).  Single link pass.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = wbstart.library

all: $(TARGET)

$(TARGET): wbstart_lib.o wbstart.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ wbstart_lib.o wbstart.o endmodule.o

wbstart_lib.o: wbstart_lib.s
	$(CC) $(ASFLAGS) -c -o $@ wbstart_lib.s

wbstart.o: wbstart.c
	$(CC) $(CFLAGS) -c -o $@ wbstart.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

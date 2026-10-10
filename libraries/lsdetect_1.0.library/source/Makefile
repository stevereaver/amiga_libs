# Makefile for lsdetect.library 1.0 C reconstruction
#
# Single code hunk, absolute-longword functab, single pass.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = lsdetect.library

all: $(TARGET)

$(TARGET): lsdetect_lib.o lsdetect.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ lsdetect_lib.o lsdetect.o endmodule.o

lsdetect_lib.o: lsdetect_lib.s
	$(CC) $(ASFLAGS) -c -o $@ lsdetect_lib.s

lsdetect.o: lsdetect.c
	$(CC) $(CFLAGS) -c -o $@ lsdetect.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

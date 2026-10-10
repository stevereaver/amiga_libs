# Makefile for the Phase5 dummy 68040.library 44.1 loader stub
#
# Builds a HUNK-format .library with the m68k-amigaos cross toolchain.
# The AUTOINIT function table is absolute-long (.long entries in
# dummy_lib.s), so no two-pass functab generation is needed.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68040
LDFLAGS = -nostdlib -nostartfiles

TARGET  = 68040.library

all: $(TARGET)

$(TARGET): dummy_lib.o dummy.o helpers.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ dummy_lib.o dummy.o helpers.o endmodule.o

dummy_lib.o: dummy_lib.s
	$(CC) $(ASFLAGS) -c -o $@ dummy_lib.s

dummy.o: dummy.c
	$(CC) $(CFLAGS) -c -o $@ dummy.c

helpers.o: helpers.s
	$(CC) $(ASFLAGS) -c -o $@ helpers.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

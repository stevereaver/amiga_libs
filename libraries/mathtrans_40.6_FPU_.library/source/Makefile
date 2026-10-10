# Makefile for mathtrans.library 40.6 (68881/82) reconstruction.
#
# Single link pass: the AUTOINIT function table is absolute
# longwords.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020 -m68881
LDFLAGS = -nostdlib -nostartfiles

TARGET  = mathtrans.library

all: $(TARGET)

OBJS = mathtrans_lib.o datatab.o mathtrans.o math.o endmodule.o

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

mathtrans_lib.o: mathtrans_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

datatab.o: datatab.s
	$(CC) $(ASFLAGS) -c -o $@ $<

math.o: math.s
	$(CC) $(ASFLAGS) -c -o $@ $<

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ $<

mathtrans.o: mathtrans.c mtbase.h
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

# Makefile for mathieeedoubtrans.library 40.6 (68881/82) reconstruction.
#
# Single link pass: the AUTOINIT function table is absolute
# longwords.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020 -m68881
LDFLAGS = -nostdlib -nostartfiles

TARGET  = mathieeedoubtrans.library

all: $(TARGET)

OBJS = mathieeedoubtrans_lib.o datatab.o mathieeedoubtrans.o math.o endmodule.o

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

mathieeedoubtrans_lib.o: mathieeedoubtrans_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

datatab.o: datatab.s
	$(CC) $(ASFLAGS) -c -o $@ $<

math.o: math.s
	$(CC) $(ASFLAGS) -c -o $@ $<

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ $<

mathieeedoubtrans.o: mathieeedoubtrans.c mdtbase.h
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

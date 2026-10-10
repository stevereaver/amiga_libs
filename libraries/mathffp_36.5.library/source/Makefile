# Makefile for mathffp.library 36.5 C reconstruction
# Commodore C= FFP math lib -- word-offset functab, packed RomTag.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
LDFLAGS = -nostdlib -nostartfiles
TARGET  = mathffp.library

$(TARGET): mathffp_lib.o mathffp.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ mathffp_lib.o mathffp.o endmodule.o

mathffp_lib.o: mathffp_lib.s
	$(CC) -m68000 -c -o $@ $<

mathffp.o: mathffp.c
	$(CC) $(CFLAGS) -c -o $@ $<

endmodule.o: endmodule.s
	$(CC) -m68000 -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

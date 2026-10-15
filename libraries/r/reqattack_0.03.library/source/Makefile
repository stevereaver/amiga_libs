# Makefile for reqattack.library 0.03 C reconstruction
# Absolute-longword functab -- single link, no two-pass needed.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
LDFLAGS = -nostdlib -nostartfiles
TARGET  = reqattack.library

$(TARGET): reqattack_lib.o reqattack.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ reqattack_lib.o reqattack.o endmodule.o

reqattack_lib.o: reqattack_lib.s
	$(CC) -m68000 -c -o $@ $<

reqattack.o: reqattack.c
	$(CC) $(CFLAGS) -c -o $@ $<

endmodule.o: endmodule.s
	$(CC) -m68000 -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

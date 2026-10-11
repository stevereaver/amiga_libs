# i2c.library 40.1 -- reconstruction build
CC	= /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS	= -O2 -m68000 -fomit-frame-pointer -fno-builtin \
	  -fno-toplevel-reorder -I/opt/amiga/m68k-amigaos/ndk-include \
	  -Wall -Wno-unused-parameter
ASFLAGS	= -m68000

all: i2c.library

i2c.library: i2c_lib.o i2c.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o $@ i2c_lib.o i2c.o endmodule.o

i2c_lib.o: i2c_lib.s
	$(CC) $(ASFLAGS) -c -o $@ i2c_lib.s

i2c.o: i2c.c
	$(CC) $(CFLAGS) -c -o $@ i2c.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o i2c.library

.PHONY: all clean

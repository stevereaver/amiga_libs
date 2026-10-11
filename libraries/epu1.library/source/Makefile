# epu1.library 1.1 -- reconstruction build
CC	= /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS	= -O2 -m68000 -fomit-frame-pointer -fno-builtin \
	  -fno-toplevel-reorder -I/opt/amiga/m68k-amigaos/ndk-include \
	  -Wall -Wno-unused-parameter
ASFLAGS	= -m68000

all: epu1.library

epu1.library: epu1_lib.o epu1.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o $@ epu1_lib.o epu1.o endmodule.o

epu1_lib.o: epu1_lib.s
	$(CC) $(ASFLAGS) -c -o $@ epu1_lib.s

epu1.o: epu1.c
	$(CC) $(CFLAGS) -c -o $@ epu1.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o epu1.library

.PHONY: all clean

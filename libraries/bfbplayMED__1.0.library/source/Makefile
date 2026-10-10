# bfbplayMED!.library V1.0 -- reconstruction build
CC	= /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS	= -O2 -m68000 -fomit-frame-pointer -fno-builtin \
	  -fno-toplevel-reorder -I/opt/amiga/m68k-amigaos/ndk-include \
	  -Wall -Wno-unused-parameter
ASFLAGS	= -m68000

all: bfbplayMED.library

bfbplayMED.library: bfbplayMED_lib.o bfbplayMED.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o $@ bfbplayMED_lib.o bfbplayMED.o endmodule.o

bfbplayMED_lib.o: bfbplayMED_lib.s
	$(CC) $(ASFLAGS) -c -o $@ bfbplayMED_lib.s

bfbplayMED.o: bfbplayMED.c
	$(CC) $(CFLAGS) -c -o $@ bfbplayMED.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o bfbplayMED.library

.PHONY: all clean

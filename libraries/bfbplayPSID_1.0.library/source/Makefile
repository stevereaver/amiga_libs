# bfbplayPSID!.library V1.0 -- reconstruction build
CC	= /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS	= -O2 -m68000 -fomit-frame-pointer -fno-builtin \
	  -fno-toplevel-reorder -I/opt/amiga/m68k-amigaos/ndk-include \
	  -Wall -Wno-unused-parameter
ASFLAGS	= -m68000

all: bfbplayPSID.library

bfbplayPSID.library: bfbplayPSID_lib.o bfbplayPSID.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o $@ bfbplayPSID_lib.o bfbplayPSID.o endmodule.o

bfbplayPSID_lib.o: bfbplayPSID_lib.s
	$(CC) $(ASFLAGS) -c -o $@ bfbplayPSID_lib.s

bfbplayPSID.o: bfbplayPSID.c
	$(CC) $(CFLAGS) -c -o $@ bfbplayPSID.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o bfbplayPSID.library

.PHONY: all clean

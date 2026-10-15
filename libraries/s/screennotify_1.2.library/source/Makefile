# screennotify.library 1.2 -- reconstruction build
CC	= /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS	= -O2 -m68000 -fomit-frame-pointer -fno-builtin \
	  -fno-toplevel-reorder -I/opt/amiga/m68k-amigaos/ndk-include \
	  -Wall -Wno-unused-parameter
ASFLAGS	= -m68000

all: screennotify.library

screennotify.library: screennotify_lib.o screennotify.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o $@ screennotify_lib.o \
		screennotify.o endmodule.o

screennotify_lib.o: screennotify_lib.s
	$(CC) $(ASFLAGS) -c -o $@ screennotify_lib.s

screennotify.o: screennotify.c
	$(CC) $(CFLAGS) -c -o $@ screennotify.c

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

clean:
	rm -f *.o screennotify.library

.PHONY: all clean

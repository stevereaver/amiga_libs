CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

OBJS    = explode_lib.o explode.o endmodule.o

explode.library: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

explode_lib.o: explode_lib.s explbase.h
	$(CC) $(ASFLAGS) -c -o $@ explode_lib.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

explode.o: explode.c explbase.h
	$(CC) $(CFLAGS) -c -o $@ explode.c

clean:
	rm -f *.o explode.library

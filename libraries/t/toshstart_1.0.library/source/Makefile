CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

toshstart.library: toshstart_lib.o toshstart.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ toshstart_lib.o toshstart.o endmodule.o

toshstart_lib.o: toshstart_lib.s
	$(CC) $(ASFLAGS) -c -o $@ toshstart_lib.s
endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s
toshstart.o: toshstart.c toshbase.h
	$(CC) $(CFLAGS) -c -o $@ toshstart.c
clean:
	rm -f *.o toshstart.library

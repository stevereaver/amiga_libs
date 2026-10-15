CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

mhimaspro.library: mhimaspro_lib.o mhimaspro.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ mhimaspro_lib.o mhimaspro.o endmodule.o
%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<
%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<
clean:
	rm -f *.o mhimaspro.library

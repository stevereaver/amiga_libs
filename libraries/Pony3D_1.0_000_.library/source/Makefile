CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

pony3d.library: pony3d_lib.o pony3d.o
	$(CC) $(LDFLAGS) -o $@ $^

pony3d_lib.o: pony3d_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

pony3d.o: pony3d.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f pony3d_lib.o pony3d.o pony3d.library

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -ffixed-a2 -ffixed-a5 -ffixed-d4 \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

rexxserdev.library: rexxserdev_lib.o rexxserdev.o
	$(CC) $(LDFLAGS) -o $@ $^

rexxserdev_lib.o: rexxserdev_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

rexxserdev.o: rexxserdev.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f rexxserdev_lib.o rexxserdev.o rexxserdev.library

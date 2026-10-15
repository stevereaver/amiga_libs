CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

xpkBZIP.library: xpkBZIP_lib.o xpkBZIP.o
	$(CC) $(LDFLAGS) -o $@ $^

xpkBZIP_lib.o: xpkBZIP_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

xpkBZIP.o: xpkBZIP.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f xpkBZIP_lib.o xpkBZIP.o xpkBZIP.library

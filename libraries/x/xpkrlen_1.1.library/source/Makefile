CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin -fno-toplevel-reorder \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

OBJS    = xpkrlen_lib.o xpkrlen.o

xpkRLEN.library: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

xpkrlen_lib.o: xpkrlen_lib.s xpkbase.h
	$(CC) $(ASFLAGS) -c -o $@ xpkrlen_lib.s

xpkrlen.o: xpkrlen.c xpkbase.h
	$(CC) $(CFLAGS) -c -o $@ xpkrlen.c

clean:
	rm -f *.o xpkRLEN.library datablob.s

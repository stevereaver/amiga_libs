# Makefile for cxb.library 37.1 C reconstruction
# Absolute-longword functab -- single link.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
LDFLAGS = -nostdlib -nostartfiles
TARGET  = cxb.library

$(TARGET): cxb_lib.o cxb.o
	$(CC) $(LDFLAGS) -o $@ cxb_lib.o cxb.o

cxb_lib.o: cxb_lib.s
	$(CC) -m68000 -c -o $@ $<

cxb.o: cxb.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

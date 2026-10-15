# Makefile for fastlayers.library 40.48 C reconstruction
# Absolute-longword functab -- single link.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
LDFLAGS = -nostdlib -nostartfiles
TARGET  = fastlayers.library

$(TARGET): fastlayers_lib.o fastlayers.o
	$(CC) $(LDFLAGS) -o $@ fastlayers_lib.o fastlayers.o

fastlayers_lib.o: fastlayers_lib.s
	$(CC) -m68000 -c -o $@ $<

fastlayers.o: fastlayers.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

# Makefile for shutdown.library 2.3 C reconstruction
CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
TARGET  = shutdown.library

$(TARGET): shutdown_lib.o shutdown.o
	$(CC) $(LDFLAGS) -o $@ shutdown_lib.o shutdown.o

shutdown_lib.o: shutdown_lib.s
	$(CC) -m68000 -c -o $@ $<

shutdown.o: shutdown.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

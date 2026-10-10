# Makefile for xpkRLEN.library V1.3 C reconstruction
#
# Builds a two-hunk HUNK .library with the m68k-amigaos cross
# toolchain.  Absolute-longword AUTOINIT functab -- single link
# pass.  Descriptors live in the .data hunk (hunk1).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkRLEN.library

all: $(TARGET)

OBJS = xpkRLEN_lib.o xpkRLEN.o

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

xpkRLEN_lib.o: xpkRLEN_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

xpkRLEN.o: xpkRLEN.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean

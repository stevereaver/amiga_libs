# Makefile for xpkSQSH.library 1.2 C reconstruction
#
# Two-pass word-offset functab: link a dummy image with a
# size-correct functab_stub.o, measure the final .text addresses,
# then generate functab.s with the real offsets.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68020 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68020
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = xpkSQSH.library

all: $(TARGET)

dummy.library: xpkSQSH_lib.o functab_stub.o xpkSQSH.o
	$(CC) $(LDFLAGS) -o $@ xpkSQSH_lib.o functab_stub.o xpkSQSH.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

xpkSQSH_lib.o: xpkSQSH_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkSQSH_lib.s

xpkSQSH.o: xpkSQSH.c
	$(CC) $(CFLAGS) -c -o $@ xpkSQSH.c

$(TARGET): xpkSQSH_lib.o functab.o xpkSQSH.o
	$(CC) $(LDFLAGS) -o $@ xpkSQSH_lib.o functab.o xpkSQSH.o

clean:
	rm -f *.o *.nm *.library dummy.library functab.s

.PHONY: all clean

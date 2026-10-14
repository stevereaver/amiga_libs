# Makefile for xpkNUKE.library 1.9 C reconstruction -- 68000 build
#
# Two-pass word-offset functab: link a dummy image with a
# size-correct functab_stub.o, measure the final .text addresses,
# then generate functab.s with the real offsets.
#
# _TagEnd (rt_EndSkip target) is split into two labels: _TagEnd in
# xpkNUKE_lib.s is a weak alias resolved by the real end-of-hunk
# marker in tail.o, which links last.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles
NM      = /opt/amiga/bin/m68k-amigaos-nm

TARGET  = xpkNUKE.library

all: $(TARGET)

dummy.library: xpkNUKE_lib.o functab_stub.o xpkNUKE.o tail.o
	$(CC) $(LDFLAGS) -o $@ xpkNUKE_lib.o functab_stub.o xpkNUKE.o tail.o

functab.s: dummy.library genfunctab.py
	$(NM) dummy.library > dummy.nm
	python3 genfunctab.py dummy.nm > $@

functab_stub.o: functab_stub.s
	$(CC) $(ASFLAGS) -c -o $@ functab_stub.s

functab.o: functab.s
	$(CC) $(ASFLAGS) -c -o $@ functab.s

xpkNUKE_lib.o: xpkNUKE_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkNUKE_lib.s

xpkNUKE.o: xpkNUKE.c
	$(CC) $(CFLAGS) -c -o $@ xpkNUKE.c

tail.o: tail.s
	$(CC) $(ASFLAGS) -c -o $@ tail.s

$(TARGET): xpkNUKE_lib.o functab.o xpkNUKE.o tail.o
	$(CC) $(LDFLAGS) -o $@ xpkNUKE_lib.o functab.o xpkNUKE.o tail.o

clean:
	rm -f *.o *.nm *.library dummy.library functab.s

.PHONY: all clean

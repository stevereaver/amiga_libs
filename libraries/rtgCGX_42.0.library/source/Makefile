CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/rtgCGX_42.0.library
OBJS    = rtgCGX_42_0_h0.o rtgCGX_42_0_h1.o rtgCGX_42_0_h2.o rtgCGX_42_0_h3.o rtgCGX_42_0_h4.o

all: rtgCGX.library

rtgCGX.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o rtgCGX.library

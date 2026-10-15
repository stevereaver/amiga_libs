CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/rtgEGS_42.0.library
OBJS    = rtgEGS_42_0_h0.o rtgEGS_42_0_h1.o rtgEGS_42_0_h2.o rtgEGS_42_0_h3.o rtgEGS_42_0_h4.o

all: rtgEGS.library

rtgEGS.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o rtgEGS.library

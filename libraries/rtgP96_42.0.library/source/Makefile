CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/rtgP96_42.0.library
OBJS    = rtgP96_42_0_h0.o rtgP96_42_0_h1.o rtgP96_42_0_h2.o rtgP96_42_0_h3.o rtgP96_42_0_h4.o

all: rtgP96.library

rtgP96.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o rtgP96.library

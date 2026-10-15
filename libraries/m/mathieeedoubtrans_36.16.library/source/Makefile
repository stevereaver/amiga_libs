CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/mathieeedoubtrans_36.16.library
OBJS    = mathieeedoubtrans_36_16_h0.o mathieeedoubtrans_36_16_h1.o

all: mathieeedoubtrans.library

mathieeedoubtrans.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o mathieeedoubtrans.library

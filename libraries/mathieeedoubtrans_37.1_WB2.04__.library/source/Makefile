CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/mathieeedoubtrans_37.1(WB2.04+).library
OBJS    = mathieeedoubtrans_37_1_WB2_04___h0.o mathieeedoubtrans_37_1_WB2_04___h1.o

all: mathieeedoubtrans.library

mathieeedoubtrans.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o mathieeedoubtrans.library

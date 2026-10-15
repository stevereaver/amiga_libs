CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/rtgAMI_42.0.library
OBJS    = rtgAMI_42_0_h0.o rtgAMI_42_0_h1.o rtgAMI_42_0_h2.o rtgAMI_42_0_h3.o rtgAMI_42_0_h4.o

all: rtgAMI.library

rtgAMI.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o rtgAMI.library

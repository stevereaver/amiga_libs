CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/akcc_gen0_37.6.library
OBJS    = akcc_gen0_37_6_h0.o akcc_gen0_37_6_h1.o akcc_gen0_37_6_h2.o akcc_gen0_37_6_h3.o akcc_gen0_37_6_h4.o

all: akcc.library

akcc.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o akcc.library

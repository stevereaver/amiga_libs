CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/xpkLZCB_1.0.library
OBJS    = xpkLZCB_1_0_h0.o xpkLZCB_1_0_h1.o xpkLZCB_1_0_h2.o xpkLZCB_1_0_h3.o

all: xpkLZCB.library

xpkLZCB.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o xpkLZCB.library

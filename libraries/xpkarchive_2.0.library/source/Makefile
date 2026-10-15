CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/xpkarchive_2.0.library
OBJS    = xpkarchive_2_0_h0.o xpkarchive_2_0_h1.o xpkarchive_2_0_h2.o xpkarchive_2_0_h3.o xpkarchive_2_0_h4.o

all: xpkarchive.library

xpkarchive.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o xpkarchive.library

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/warpsdl_0.4.library
OBJS    = warpsdl_0_4_h0.o warpsdl_0_4_h1.o warpsdl_0_4_h2.o warpsdl_0_4_h3.o warpsdl_0_4_h4.o warpsdl_0_4_h5.o

all: warpsdl.library

warpsdl.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o warpsdl.library

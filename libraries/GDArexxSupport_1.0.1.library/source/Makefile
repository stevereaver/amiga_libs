CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/GDArexxSupport_1.0.1.library
OBJS    = GDArexxSupport_1_0_1_h0.o GDArexxSupport_1_0_1_h1.o GDArexxSupport_1_0_1_h2.o

all: GDArexxSupport.library

GDArexxSupport.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o GDArexxSupport.library

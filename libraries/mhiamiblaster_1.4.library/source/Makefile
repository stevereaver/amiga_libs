CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/mhiamiblaster_1.4.library
OBJS    = mhiamiblaster_1_4_h0.o mhiamiblaster_1_4_h1.o mhiamiblaster_1_4_h2.o

all: mhiamiblaster.library

mhiamiblaster.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o mhiamiblaster.library

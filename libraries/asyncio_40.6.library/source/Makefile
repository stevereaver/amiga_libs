CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/asyncio_40.6.library
OBJS    = asyncio_40_6_h0.o asyncio_40_6_h1.o asyncio_40_6_h2.o asyncio_40_6_h3.o asyncio_40_6_h4.o asyncio_40_6_h5.o

all: asyncio.library

asyncio.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o asyncio.library

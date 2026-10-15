CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/resource_44.102(WB3.5).library
OBJS    = resource_44_102_WB3_5__h0.o resource_44_102_WB3_5__h1.o resource_44_102_WB3_5__h2.o resource_44_102_WB3_5__h3.o

all: resource.library

resource.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o resource.library

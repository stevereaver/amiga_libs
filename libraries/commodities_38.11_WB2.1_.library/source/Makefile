CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/commodities_38.11(WB2.1).library
OBJS    = commodities_38_11_WB2_1__h0.o commodities_38_11_WB2_1__h1.o commodities_38_11_WB2_1__h2.o commodities_38_11_WB2_1__h3.o

all: commodities.library

commodities.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o commodities.library

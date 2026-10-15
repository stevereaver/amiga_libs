CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/Picasso96API_2.310(P96).library
OBJS    = Picasso96API_2_310_P96__h0.o Picasso96API_2_310_P96__h1.o Picasso96API_2_310_P96__h2.o Picasso96API_2_310_P96__h3.o Picasso96API_2_310_P96__h4.o

all: Picasso96API.library

Picasso96API.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o Picasso96API.library

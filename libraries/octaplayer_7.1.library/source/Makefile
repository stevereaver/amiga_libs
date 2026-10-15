CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/octaplayer_7.1.library
OBJS    = octaplayer_7_1_h0.o octaplayer_7_1_h1.o octaplayer_7_1_h2.o octaplayer_7_1_h3.o octaplayer_7_1_h4.o octaplayer_7_1_h5.o octaplayer_7_1_h6.o octaplayer_7_1_h7.o

all: octaplayer.library

octaplayer.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o octaplayer.library

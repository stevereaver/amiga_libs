CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/octamixplayer_7.1.library
OBJS    = octamixplayer_7_1_h0.o octamixplayer_7_1_h1.o octamixplayer_7_1_h2.o octamixplayer_7_1_h3.o octamixplayer_7_1_h4.o octamixplayer_7_1_h5.o octamixplayer_7_1_h6.o

all: octamixplayer.library

octamixplayer.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o octamixplayer.library

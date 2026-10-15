CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/medplayer_1.0.library
OBJS    = medplayer_1_0_h0.o medplayer_1_0_h1.o medplayer_1_0_h2.o medplayer_1_0_h3.o medplayer_1_0_h5.o medplayer_1_0_h6.o

all: medplayer.library

medplayer.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o medplayer.library

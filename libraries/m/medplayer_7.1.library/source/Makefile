CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/medplayer_7.1.library
OBJS    = medplayer_7_1_h0.o medplayer_7_1_h1.o medplayer_7_1_h2.o medplayer_7_1_h3.o medplayer_7_1_h4.o medplayer_7_1_h5.o medplayer_7_1_h6.o medplayer_7_1_h7.o medplayer_7_1_h8.o medplayer_7_1_h9.o

all: medplayer.library

medplayer.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o medplayer.library

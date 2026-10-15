CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/inovamusic_3.1.library
OBJS    = inovamusic_3_1_h0.o inovamusic_3_1_h1.o inovamusic_3_1_h3.o inovamusic_3_1_h4.o inovamusic_3_1_h5.o

all: inovamusic.library

inovamusic.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o inovamusic.library

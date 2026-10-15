CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/imagepool0.8.library
OBJS    = imagepool0_8_h0.o imagepool0_8_h1.o imagepool0_8_h2.o imagepool0_8_h3.o

all: imagepool0.8.library.library

imagepool0.8.library.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o imagepool0.8.library.library

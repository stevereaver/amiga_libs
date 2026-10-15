CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/rexxreqtools_37.95.library
OBJS    = rexxreqtools_37_95_h0.o rexxreqtools_37_95_h1.o rexxreqtools_37_95_h2.o rexxreqtools_37_95_h3.o

all: rexxreqtools.library

rexxreqtools.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o rexxreqtools.library

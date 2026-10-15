CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/ak_34.12.library
OBJS    = ak_34_12_h0.o ak_34_12_h1.o ak_34_12_h2.o ak_34_12_h4.o ak_34_12_h5.o ak_34_12_h6.o ak_34_12_h7.o ak_34_12_h8.o ak_34_12_h9.o

all: ak.library

ak.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o ak.library

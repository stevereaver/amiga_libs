CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/xprftp_1.0.library
OBJS    = xprftp_1_0_h0.o xprftp_1_0_h1.o xprftp_1_0_h2.o

all: xprftp.library

xprftp.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o xprftp.library

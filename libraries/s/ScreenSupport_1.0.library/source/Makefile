CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/ScreenSupport_1.0.library
OBJS    = ScreenSupport_1_0_h0.o ScreenSupport_1_0_h1.o ScreenSupport_1_0_h2.o ScreenSupport_1_0_h3.o ScreenSupport_1_0_h4.o

all: ScreenSupport.library

ScreenSupport.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o ScreenSupport.library

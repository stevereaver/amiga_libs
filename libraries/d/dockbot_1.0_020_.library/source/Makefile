CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/dockbot_1.0(020).library
OBJS    = dockbot_1_0_020__h0.o dockbot_1_0_020__h1.o dockbot_1_0_020__h2.o dockbot_1_0_020__h3.o dockbot_1_0_020__h4.o

all: dockbot.library

dockbot.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o dockbot.library

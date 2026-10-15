CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/serio-comic_5.0.library
OBJS    = serio_comic_5_0_h0.o serio_comic_5_0_h1.o serio_comic_5_0_h2.o serio_comic_5_0_h3.o serio_comic_5_0_h4.o serio_comic_5_0_h5.o serio_comic_5_0_h6.o

all: serio-comic.library

serio-comic.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o serio-comic.library

CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: dtimage.library

dtimage.library: dt_h0.o dt_h1.o
	$(CC) $(CFLAGS) -o $@ dt_h0.o dt_h1.o
	python3 fixup.py $@
	cmp $@ "../binary/dtimage_3.3.library" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o dtimage.library

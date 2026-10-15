CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: wbstart.library

wbstart_hunks.o: wbstart_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

wbstart.library: wbstart_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@ "../binary/wbstart_2.0.library"
	cmp $@ "../binary/wbstart_2.0.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o wbstart.library

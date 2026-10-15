CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: f1gp.library

f1gp_hunks.o: f1gp_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

f1gp.library: f1gp_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/f1gp_36.10.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o f1gp.library

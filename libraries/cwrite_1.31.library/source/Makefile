CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: cwrite.library

cwrite_h0.o: cwrite_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

cwrite.library: cwrite_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/cwrite_1.31.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o cwrite.library

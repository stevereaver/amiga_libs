CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: multifunction.library

mf_h0.o: mf_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

multifunction.library: mf_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/multifunction_38.1.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o multifunction.library

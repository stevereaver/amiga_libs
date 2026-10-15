CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: stopus.library

stopus_h0.o: stopus_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

stopus.library: stopus_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/stopus_1.1.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o stopus.library

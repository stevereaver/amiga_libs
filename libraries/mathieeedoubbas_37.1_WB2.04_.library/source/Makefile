CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: mdb.library

mdb_h0.o: mdb_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

mdb.library: mdb_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/mathieeedoubbas_37.1(WB2.04).library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o mdb.library

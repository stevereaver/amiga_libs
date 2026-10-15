CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: pony3d.library

pony3d.library: pony3d_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/Pony3D_1.0(020+).library" && echo BYTE-IDENTICAL

pony3d_h0.o: pony3d_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o pony3d.library

.PHONY: all clean

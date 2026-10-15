CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: nonvolatile.library

nonvolatile.library: nonvolatile_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/nonvolatile_40.36(WB3.1).library" && echo BYTE-IDENTICAL

nonvolatile_h0.o: nonvolatile_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o nonvolatile.library

.PHONY: all clean

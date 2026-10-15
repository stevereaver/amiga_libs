CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: iconobject.library

iconobject.library: iconobject_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/iconobject_40.8.library && echo BYTE-IDENTICAL

iconobject_h0.o: iconobject_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o iconobject.library

.PHONY: all clean

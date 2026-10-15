CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: launcher.library

launcher.library: launcher_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/launcher_41.9.library && echo BYTE-IDENTICAL

launcher_h0.o: launcher_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o launcher.library

.PHONY: all clean

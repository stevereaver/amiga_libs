CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: uuid.library

uuid.library: uuid_hunks.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ "../binary/uuid_2.0.0.library" && echo BYTE-IDENTICAL

uuid_hunks.o: uuid_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o uuid.library
.PHONY: all clean

CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: regexp.library

regexp.library: rx_h0.o rx_h1.o
	$(CC) $(CFLAGS) -o $@ rx_h0.o rx_h1.o
	python3 fixup.py $@
	cmp $@ "../binary/regexp_38.1.library" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o regexp.library

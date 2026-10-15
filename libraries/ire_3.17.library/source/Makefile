CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles
all: ire.library
ire.library: ire_h0.o ire_h1.o ire_h2.o ire_h3.o
	$(CC) $(CFLAGS) -o $@ ire_h0.o ire_h1.o ire_h2.o ire_h3.o
	python3 fixup.py $@
	cmp $@ "../binary/ire_3.17.library" && echo BYTE-IDENTICAL
%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

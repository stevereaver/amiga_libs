CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: notifyintuition.library

notifyintuition_h0.o: notifyintuition_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

notifyintuition.library: notifyintuition_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/notifyintuition_2.40.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o notifyintuition.library

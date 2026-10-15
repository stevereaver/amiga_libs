CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: virtualmem.library

vm_hunks.o: vm_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

virtualmem.library: vm_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/virtualmem_1.2.library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o virtualmem.library

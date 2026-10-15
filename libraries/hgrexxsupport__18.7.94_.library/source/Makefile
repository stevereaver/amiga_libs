CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: hgrexxsupport.library

hgr_hunks.o: hgr_hunks.s
	$(CC) $(CFLAGS) -c -o $@ $<

hgrexxsupport.library: hgr_hunks.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/hgrexxsupport_(18.7.94).library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o hgrexxsupport.library

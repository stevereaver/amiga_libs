CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -s

tdisk.library: tdisk_lib.o reorder_relocs.py
	$(CC) $(LDFLAGS) -o $@ tdisk_lib.o
	python3 reorder_relocs.py $@

tdisk_lib.o: tdisk_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f tdisk_lib.o tdisk.library

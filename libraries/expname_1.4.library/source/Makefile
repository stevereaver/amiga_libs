CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -s

expname.library: expname_lib.o
	$(CC) $(LDFLAGS) -o $@ $^
	python3 drel16.py $@

expname_lib.o: expname_lib.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f expname_lib.o expname.library

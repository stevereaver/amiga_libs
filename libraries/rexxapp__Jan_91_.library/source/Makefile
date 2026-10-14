CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -s

rexxapp.library: rexxapp.ld
	python3 fixhdr.py rexxapp.ld $@

rexxapp.ld: rexxapp.o
	$(CC) $(LDFLAGS) -o $@ $^

rexxapp.o: rexxapp.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f rexxapp.o rexxapp.ld rexxapp.library

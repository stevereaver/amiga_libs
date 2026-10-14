CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -s

rexxsupport.library: rexxsupport.o
	$(CC) $(LDFLAGS) -o $@ $^

rexxsupport.o: rexxsupport.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f rexxsupport.o rexxsupport.library

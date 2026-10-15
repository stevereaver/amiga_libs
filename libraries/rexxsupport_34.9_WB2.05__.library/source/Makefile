CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -s

rexxsupport.library: rexxsupport.o
	$(CC) $(LDFLAGS) -o $@ $^
	python3 fixup.py $@
	cmp $@ "../binary/rexxsupport_34.9(WB2.05+).library" && echo BYTE-IDENTICAL

rexxsupport.o: rexxsupport.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f rexxsupport.o rexxsupport.library

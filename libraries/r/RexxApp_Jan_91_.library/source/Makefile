CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -s

rexxapp.library: rexxapp.ld
	python3 fixup.py rexxapp.ld $@

rexxapp.ld: RexxApp_h0.o
	$(CC) $(LDFLAGS) -o $@ $^

RexxApp_h0.o: RexxApp_h0.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f RexxApp_h0.o rexxapp.ld rexxapp.library

.PHONY: clean

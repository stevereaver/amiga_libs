CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000 -Wa,-m68881
LDFLAGS = -nostdlib -nostartfiles -s

mathtrans.library: mathtrans.o
	$(CC) $(LDFLAGS) -o $@ $^
	python3 drel16.py $@

mathtrans.o: mathtrans.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f mathtrans.o mathtrans.library

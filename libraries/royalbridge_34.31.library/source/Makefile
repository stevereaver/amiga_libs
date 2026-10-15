AS=/opt/amiga/bin/m68k-amigaos-gcc
royalbridge.library: h0.o h1.o
	$(AS) -nostdlib -nostartfiles -o $@ h0.o h1.o
	python3 fixup.py $@
	cmp $@ ../binary/royalbridge_34.31.library && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o royalbridge.library

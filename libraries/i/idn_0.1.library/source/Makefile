AS=/opt/amiga/bin/m68k-amigaos-gcc
idn.library: h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/idn_0.1.library && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o idn.library

AS=/opt/amiga/bin/m68k-amigaos-gcc
rexxidentify.library: rexxid_h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/rexxidentify_1.12.library && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68020 -c -o $@ $<
clean:
	rm -f *.o rexxidentify.library

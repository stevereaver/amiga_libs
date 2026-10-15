AS=/opt/amiga/bin/m68k-amigaos-gcc
maestix.library: h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/maestix_42.00(020+).library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68020 -c -o $@ $<
clean:
	rm -f *.o maestix.library

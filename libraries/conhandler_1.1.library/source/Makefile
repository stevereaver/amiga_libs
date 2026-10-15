AS=/opt/amiga/bin/m68k-amigaos-gcc
conhandler.library: h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/conhandler_1.1.library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o conhandler.library

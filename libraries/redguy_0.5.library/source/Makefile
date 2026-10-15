AS=/opt/amiga/bin/m68k-amigaos-gcc
redguy.library: rg_h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/redguy_0.5.library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68020 -c -o $@ $<
clean:
	rm -f *.o redguy.library

AS=/opt/amiga/bin/m68k-amigaos-gcc
stc.library: h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/stc_3.41(020+).library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o stc.library

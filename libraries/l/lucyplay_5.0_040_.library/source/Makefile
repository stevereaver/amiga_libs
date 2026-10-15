AS=/opt/amiga/bin/m68k-amigaos-gcc
lucyplay.library: lucyplay_h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/lucyplay_5.0(040).library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o lucyplay.library

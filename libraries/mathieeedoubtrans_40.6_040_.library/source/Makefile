AS=/opt/amiga/bin/m68k-amigaos-gcc
mathieeedoubtrans.library: mdt_h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/mathieeedoubtrans_40.6(040).library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68020 -c -o $@ $<
clean:
	rm -f *.o mathieeedoubtrans.library

AS=/opt/amiga/bin/m68k-amigaos-gcc
powerpacker.library: pp_h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/PowerPacker_37.7(020)(23.07.01).library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o powerpacker.library

AS=/opt/amiga/bin/m68k-amigaos-gcc
iffparse.library: iffparse_h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/iffparse_42.2(BUGGED).library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o iffparse.library

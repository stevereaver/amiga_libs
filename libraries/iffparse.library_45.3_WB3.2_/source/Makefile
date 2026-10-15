AS=/opt/amiga/bin/m68k-amigaos-gcc
iffparse.library: h0.o h1.o
	$(AS) -nostdlib -nostartfiles -o $@ h0.o h1.o
	python3 fixup.py $@
	cmp $@ "../binary/iffparse.library_45.3(WB3.2)" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o iffparse.library

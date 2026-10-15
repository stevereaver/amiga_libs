AS=/opt/amiga/bin/m68k-amigaos-gcc
quickdos.library: qd_h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/quickdos_1.01.library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68020 -c -o $@ $<
clean:
	rm -f *.o quickdos.library

AS=/opt/amiga/bin/m68k-amigaos-gcc
xpkLIN4.library: lin4_h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/xpkLIN4_1.1(000).library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68020 -c -o $@ $<
clean:
	rm -f *.o xpkLIN4.library

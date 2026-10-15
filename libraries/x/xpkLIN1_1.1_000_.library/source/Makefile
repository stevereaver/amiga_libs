AS=/opt/amiga/bin/m68k-amigaos-gcc
xpkLIN1.library: lin1_h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/xpkLIN1_1.1(000).library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68020 -c -o $@ $<
clean:
	rm -f *.o xpkLIN1.library

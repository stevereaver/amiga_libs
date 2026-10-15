AS=/opt/amiga/bin/m68k-amigaos-gcc
xpkRAKE.library: h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/xpkRAKE_1.8(020).library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68020 -c -o $@ $<
clean:
	rm -f *.o xpkRAKE.library

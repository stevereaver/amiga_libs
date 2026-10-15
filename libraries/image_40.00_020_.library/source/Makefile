AS=/opt/amiga/bin/m68k-amigaos-gcc
image.library: im_h0.o im_h1.o
	$(AS) -nostdlib -nostartfiles -o $@ $^
	python3 fixup.py $@
	cmp $@ "../binary/image_40.00(020).library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68020 -c -o $@ $<
clean:
	rm -f *.o image.library

AS=/opt/amiga/bin/m68k-amigaos-gcc
xardummy.library: h0.o h1.o h2.o h3.o h4.o
	$(AS) -nostdlib -nostartfiles -o $@ h0.o h1.o h2.o h3.o h4.o
	python3 fixup.py $@
	cmp $@ "../binary/xarDUMMY_1.0.library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o xardummy.library

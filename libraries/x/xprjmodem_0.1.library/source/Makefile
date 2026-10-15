AS=/opt/amiga/bin/m68k-amigaos-gcc
xprjmodem.library: h0.o h1.o
	$(AS) -nostdlib -nostartfiles -o $@ h0.o h1.o
	python3 fixup.py $@
	cmp $@ "../binary/xprjmodem_0.1.library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o xprjmodem.library

AS=/opt/amiga/bin/m68k-amigaos-gcc
xprdmodem.library: h0.o
	$(AS) -nostdlib -nostartfiles -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/xprdmodem_2.6.library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o xprdmodem.library

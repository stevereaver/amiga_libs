AS=/opt/amiga/bin/m68k-amigaos-gcc
rexxextreq.library: rx_h0.o rx_h1.o rx_h2.o
	$(AS) -nostdlib -nostartfiles -o $@ $^
	python3 fixup.py $@
	cmp $@ "../binary/rexxextreq_1.0.library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o rexxextreq.library

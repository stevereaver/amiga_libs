AS=/opt/amiga/bin/m68k-amigaos-gcc
midi.library: h0.o h1.o
	$(AS) -nostdlib -nostartfiles -o $@ h0.o h1.o
	python3 fixup.py $@
	cmp $@ "../binary/midi_2.0.library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o midi.library

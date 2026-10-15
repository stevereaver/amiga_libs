AS=/opt/amiga/bin/m68k-amigaos-gcc
icon.library: ic_code.o ic_data.o
	$(AS) -nostdlib -nostartfiles -o $@ $^
	python3 fixup.py $@
	cmp $@ "../binary/icon_1.104(WB1.0).library" && echo BYTE-IDENTICAL
%.o: %.s
	$(AS) -m68000 -c -o $@ $<
clean:
	rm -f *.o icon.library

# cgxvideo.library 41.12 (020)(CGX3) -- byte-exact reconstruction.
# 4 hunks: CODE h0 (0x21c), DATA h1 (0x24), CODE h2 (0x1278), CODE h3 (0x80).
# GNU ld pools the three .text inputs into one CODE hunk; fixup.py pools
# the linked bodies per type, verifies them against the original slices and
# re-splices the original hunk frame (headers + RELOC32 + HUNK_SYMBOL tail).

AS=/opt/amiga/bin/m68k-amigaos-gcc

cgxvideo.library: cgx_h0.o cgx_h1.o cgx_h2.o cgx_h3.o fixup.py
	$(AS) -nostdlib -nostartfiles -o $@ cgx_h0.o cgx_h1.o cgx_h2.o cgx_h3.o
	python3 fixup.py $@
	cmp $@ "../binary/cgxvideo_41.12(020)(CGX3).library" && echo BYTE-IDENTICAL

%.o: %.s
	$(AS) -m68020 -c -o $@ $<

clean:
	rm -f *.o cgxvideo.library

.PHONY: all clean

CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: mixer.library

mixer.library: mixer_h0.o
	$(CC) $(CFLAGS) -o $@ $< -Wl,-s
	python3 fixup.py $@
	cmp $@ ../binary/mixer_1.11.library && echo BYTE-IDENTICAL

mixer_h0.o: mixer_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o mixer.library

.PHONY: all clean

CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68000 -nostdlib -nostartfiles

all: rexxmathlib.library

rm_h0.o: rm_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<
rm_h1.o: rm_h1.s
	$(CC) $(CFLAGS) -c -o $@ $<

rexxmathlib.library: rm_h0.o rm_h1.o
	$(CC) $(CFLAGS) -o $@ $^
	python3 fixup.py $@
	cmp $@ "../binary/rexxmathlib_38.03(WB3.9).library" && echo BYTE-IDENTICAL

clean:
	rm -f *.o rexxmathlib.library

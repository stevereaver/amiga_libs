CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: mathtrans.library

mathtrans.library: mathtrans_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ "../binary/mathtrans_1.3(WB1.0).library" && echo BYTE-IDENTICAL

mathtrans_h0.o: mathtrans_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o mathtrans.library

.PHONY: all clean
